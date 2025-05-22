require 'rails_helper'

RSpec.describe "ErrorNotifications" do
  # Define a test error handler that mirrors our initializer logic
  def notify_error(error)
    message = "#{error.class}: #{error.message}"
    
    # Email notification if configured
    if ENV["ERROR_EMAIL"].present?
      ActionMailer::Base.mail(
        to: ENV["ERROR_EMAIL"],
        from: ENV.fetch("DEFAULT_EMAIL_FROM", "noreply@example.com"),
        subject: "[ERROR] #{message}",
        body: "#{message}\n\n#{error.backtrace&.join("\n")}"
      ).deliver_later
    end
    
    # Ntfy notification
    NtfyService.notify(message)
  end
  
  describe "error notifications" do
    let(:error) { StandardError.new("Test error message") }
    let(:mail_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      allow(ENV).to receive(:[]).with("ERROR_EMAIL").and_return("test@example.com")
      allow(ENV).to receive(:fetch).with("DEFAULT_EMAIL_FROM", anything).and_return("noreply@example.com")
      allow(ActionMailer::Base).to receive(:mail).and_return(mail_delivery)
      allow(NtfyService).to receive(:notify)
    end

    it "sends both email and ntfy notifications when ERROR_EMAIL is set" do
      notify_error(error)
      
      expect(ActionMailer::Base).to have_received(:mail).with(
        hash_including(
          to: "test@example.com",
          subject: "[ERROR] StandardError: Test error message"
        )
      )
      expect(NtfyService).to have_received(:notify).with("StandardError: Test error message")
    end

    it "skips email but still sends ntfy when ERROR_EMAIL is not set" do
      allow(ENV).to receive(:[]).with("ERROR_EMAIL").and_return(nil)
      
      notify_error(error)
      
      expect(ActionMailer::Base).not_to have_received(:mail)
      expect(NtfyService).to have_received(:notify).with("StandardError: Test error message")
    end
  end
end