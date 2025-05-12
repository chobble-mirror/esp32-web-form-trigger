class SubmissionMailer < ApplicationMailer
  # Add callbacks for email delivery to update submission status
  after_deliver :mark_as_delivered
  rescue_from StandardError, with: :mark_as_failed

  def new_submission(submission)
    @submission = submission
    @form = submission.form
    @device = submission.device

    mail(
      to: @form.target_email_address,
      subject: "New form submission from #{@device.name}"
    )
  end
<<<<<<< HEAD

  private

  def mark_as_delivered
    EmailDeliveryCallbackJob.perform_later(@submission.id, "delivered")
  end

  def mark_as_failed(exception)
    Rails.logger.error "Email delivery failed: #{exception.message}"
    EmailDeliveryCallbackJob.perform_later(@submission.id, "failed")
    raise exception # Re-raise so that the job can be retried
  end
=======
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
end
