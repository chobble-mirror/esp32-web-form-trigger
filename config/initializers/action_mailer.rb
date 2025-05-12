# Configure Action Mailer settings for the application

# Always raise errors in development to debug mailer issues
Rails.application.config.action_mailer.raise_delivery_errors = true

# Set up email delivery method - use :smtp in production/development, :test in test
Rails.application.config.action_mailer.delivery_method = Rails.env.test? ? :test : :smtp

# Configure SMTP settings for all non-test environments
unless Rails.env.test?
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

# Development and production environments both use SMTP
