namespace :test do
  desc "Test email and ntfy directly without going through Rails error handler"
  task notifications: :environment do
    # Enable debug mode for this task
    ENV["DEBUG"] = "true"
    
    begin
      puts "Testing notifications directly..."
      puts "ERROR_EMAIL: #{ENV['ERROR_EMAIL'] || 'not configured'}"
      puts "NTFY_CHANNEL: #{ENV['NTFY_CHANNEL'] || 'not configured'}"
      
      # Test email
      if ENV["ERROR_EMAIL"].present?
        puts "Sending test email to #{ENV['ERROR_EMAIL']}..."
        mail = ActionMailer::Base.mail(
          to: ENV["ERROR_EMAIL"],
          from: ENV.fetch("DEFAULT_EMAIL_FROM", "noreply@example.com"),
          subject: "Test email from Rails app",
          body: "This is a test email sent at #{Time.current}"
        )
        
        # Use deliver_now for immediate delivery in test
        begin
          result = mail.deliver_now
          puts "Email delivery result: #{result.inspect}"
          puts "Test email sent."
        rescue => e
          puts "Email delivery error: #{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
        end
      else
        puts "ERROR_EMAIL not configured, skipping email test."
      end
      
      # Test ntfy
      if ENV["NTFY_CHANNEL"].present?
        puts "Sending test ntfy notification to channel #{ENV['NTFY_CHANNEL']}..."
        begin
          # Use the synchronous method for testing
          response = NtfyService.send_notification_sync("Test notification from Rails app at #{Time.current}")
          puts "Ntfy delivery response: #{response.inspect}"
          puts "Test ntfy notification sent."
        rescue => e
          puts "Ntfy delivery error: #{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
        end
      else
        puts "NTFY_CHANNEL not configured, skipping ntfy test."
      end
      
      puts "Testing complete."
    rescue => e
      puts "Error during notification test: #{e.class}: #{e.message}"
      puts e.backtrace.join("\n")
    ensure
      # Disable debug mode after the task
      ENV["DEBUG"] = nil
    end
  end
end