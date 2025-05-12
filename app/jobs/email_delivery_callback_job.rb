class EmailDeliveryCallbackJob < ApplicationJob
  queue_as :default

  # This job updates the status of a submission after an email has been sent or failed
  def perform(submission_id, status)
    submission = Submission.find_by(id: submission_id)
    return unless submission

    if status == "delivered"
      submission.mark_as_emailed!
    elsif status == "failed"
      submission.mark_as_failed!
    end
  end
end
