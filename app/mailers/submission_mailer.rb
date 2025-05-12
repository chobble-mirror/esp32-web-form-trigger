class SubmissionMailer < ApplicationMailer
  # Add callbacks for email delivery to update submission status
  after_deliver :mark_as_delivered
  rescue_from StandardError, with: :mark_as_failed
  
  # Track delivery for all emails
  before_deliver :ensure_delivery_tracking

  def new_submission(submission)
    @submission = submission
    @form = submission.form
    @device = submission.device

    mail(
      to: @form.target_email_address,
      subject: "New form submission from #{@device.name}"
    )
  end

  private
  
  def ensure_delivery_tracking
    # Store the submission ID to ensure we can track it
    message.delivery_method.settings[:submission_id] = @submission.id if @submission
  end

  def mark_as_delivered
    EmailDeliveryCallbackJob.perform_later(@submission.id, "delivered")
  end

  def mark_as_failed(exception)
    error_message = "#{exception.class}: #{exception.message}"
    Rails.logger.error "Email delivery failed: #{error_message}"
    
    # Store backtrace for debugging purposes
    if exception.backtrace.present?
      error_message += "\n\nBacktrace:\n" + exception.backtrace.first(10).join("\n")
    end
    
    EmailDeliveryCallbackJob.perform_later(@submission.id, "failed", error_message)
    raise exception # Re-raise so that the job can be retried
  end
end
