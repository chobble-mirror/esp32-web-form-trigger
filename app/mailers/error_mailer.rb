class ErrorMailer < ApplicationMailer
  def error_notification(exception, request = nil)
    @exception = exception
    @request = request
    @backtrace = exception.backtrace || []

    error_email = ENV["ERROR_EMAIL"]
    return unless error_email.present?

    subject = "[ERROR] #{exception.class}: #{exception.message}"
    mail(to: error_email, subject: subject)
  end
end
