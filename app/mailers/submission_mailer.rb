class SubmissionMailer < ApplicationMailer
  def new_submission(submission)
    @submission = submission
    @form = submission.form
    @device = submission.device

    mail(
      to: @form.target_email_address,
      subject: "New form submission from #{@device.name}"
    )
  end
end
