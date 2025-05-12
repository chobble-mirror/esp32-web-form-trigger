# Configure Action Mailer settings for the application

# Set up email delivery method - use :smtp in production, :test in development/test
Rails.application.config.action_mailer.delivery_method = Rails.env.production? ? :smtp : :test

# Configure SMTP settings if in production
if Rails.env.production?
  Rails.application.config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_SERVER", "smtp.example.com"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    domain: ENV.fetch("SMTP_DOMAIN", "example.com"),
    user_name: ENV.fetch("SMTP_USERNAME", nil),
    password: ENV.fetch("SMTP_PASSWORD", nil),
    authentication: ENV.fetch("SMTP_AUTH", "plain"),
    enable_starttls_auto: ENV.fetch("SMTP_STARTTLS", "true") == "true"
  }
end

# Set the host for URL generation in emails
Rails.application.config.action_mailer.default_url_options = {
  host: ENV.fetch("APP_HOST", "localhost"),
  port: ENV.fetch("APP_PORT", Rails.env.development? ? 3000 : nil)
}

# Configure default email settings
Rails.application.config.action_mailer.default_options = {
  from: ENV.fetch("DEFAULT_EMAIL_FROM", "noreply@example.com")
}

# Set up Active Job as the queuing backend for Action Mailer
Rails.application.config.action_mailer.queue_adapter = :solid_queue
