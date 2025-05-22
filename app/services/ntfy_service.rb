require "net/http"

class NtfyService
  class << self
    def notify(message)
      puts "NtfyService: About to send notification in #{Thread.current.object_id}"
      puts "NtfyService: Message: #{message}"

      # Use a background thread for normal operation
      Thread.new do
        send_notification(message)
      rescue => e
        Rails.logger.error("NtfyService error: #{e.message}")
      ensure
        ActiveRecord::Base.connection_pool.release_connection
      end
    end

    # Direct synchronous sending - used for debugging
    def send_notification_sync(message)
      send_notification(message, sync: true)
    end

    private

    def send_notification(message, sync: false)
      # Validate channel configuration
      channel = ENV["NTFY_CHANNEL"]
      if channel.blank?
        puts "NtfyService: No NTFY_CHANNEL configured"
        return
      end

      puts "NtfyService: Sending to channel #{channel}"

      # Setup HTTP request
      uri = URI.parse("https://ntfy.sh/#{channel}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5

      request = Net::HTTP::Post.new(uri.path)
      request["Title"] = "patlog notification"
      request["Priority"] = "high"
      request["Tags"] = "warning"
      request.body = message

      # Send request and handle response
      response = http.request(request)

      puts "NtfyService: Response status: #{response.code}"

      # Return response for sync mode
      response
    rescue => e
      # Handle errors based on sync mode
      if sync
        puts "NtfyService error: #{e.class}: #{e.message}"
        raise
      else
        Rails.logger.error("NtfyService error: #{e.message}")
        nil
      end
    end
  end
end
