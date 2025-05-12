class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_EMAIL_FROM", "noreply@example.com")
  layout "mailer"
end
