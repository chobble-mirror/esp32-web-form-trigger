# Simple error notifier that sends errors to configured channels
class ErrorNotifier
  def report(error, handled:, severity:, source:, context:)
    # Skip non-production errors unless it's our test
    in_test = source == "test_rake_task"
    return unless Rails.env.production? || in_test

    begin
      puts "ErrorNotifier: Processing error #{error.class}: #{error.message}"

      # Email notification if ERROR_EMAIL is configured
      if defined?(ErrorMailer) && ENV["ERROR_EMAIL"].present?
        # Use Rails mailer if available
        begin
          puts "ErrorNotifier: Sending email to #{ENV["ERROR_EMAIL"]}"

          mail = ErrorMailer.error_notification(error, context[:request])

          # In test mode, deliver immediately
          if in_test
            mail.deliver_now
            puts "ErrorNotifier: Email sent"
          else
            mail.deliver_later
          end
        rescue => e
          puts "ErrorNotifier: Email error - #{e.message}"
          Rails.logger.error("Error notification email failed: #{e.message}")
        end
      end

      # Ntfy notification
      if ENV["NTFY_CHANNEL"].present?
        begin
          message = "#{error.class}: #{error.message}"

          puts "ErrorNotifier: Sending ntfy notification"
          if in_test
            response = NtfyService.send_notification_sync(message)
            puts "ErrorNotifier: Ntfy sent, status: #{response.code}"
          else
            NtfyService.notify(message)
          end
        rescue => e
          puts "ErrorNotifier: Ntfy error - #{e.message}"
          Rails.logger.error("Error notification ntfy failed: #{e.message}")
        end
      end
    rescue => e
      # Log any errors in the error handler itself
      Rails.logger.error("Error notifier failed: #{e.message}")
      puts "ErrorNotifier failed: #{e.message}"
    end
  end
end

# Register the error notifier with Rails
Rails.application.config.after_initialize do
  Rails.error.subscribe(ErrorNotifier.new)
  puts "ErrorNotifier: Registered with Rails.error"
end
