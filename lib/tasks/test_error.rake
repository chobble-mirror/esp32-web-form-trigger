namespace :test do
  desc "Test error notifications by triggering a test error"
  task error: :environment do
    # Enable debug mode for this task
    ENV["DEBUG"] = "true"
    
    begin
      puts "Testing error notifications..."
      puts "ERROR_EMAIL: #{ENV['ERROR_EMAIL'] || 'not configured'}"
      puts "NTFY_CHANNEL: #{ENV['NTFY_CHANNEL'] || 'not configured'}"
      
      # Create a test error with backtrace
      error = StandardError.new("Test error from rake task")
      error.set_backtrace(caller)
      
      # Report the error to Rails error system
      puts "Sending test error notification..."
      Rails.error.report(
        error, 
        handled: false, 
        severity: :error, 
        source: "test_rake_task",
        context: { test: true }
      )
      
      puts "Notification sent!"
      puts "- Check your email at #{ENV['ERROR_EMAIL']}" if ENV['ERROR_EMAIL'].present?
      puts "- Check your ntfy notifications at https://ntfy.sh/#{ENV['NTFY_CHANNEL']}" if ENV['NTFY_CHANNEL'].present?
    rescue => e
      puts "Failed to send error notification: #{e.class}: #{e.message}"
    ensure
      ENV["DEBUG"] = nil
    end
  end
end