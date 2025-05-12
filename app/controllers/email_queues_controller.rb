class EmailQueuesController < ApplicationController
  before_action :require_admin

  def index
    # Since we don't have SolidQueue tables yet, let's focus on submission email statuses
    @pending_submissions = Submission.where(email_status: "pending")
      .order(created_at: :desc)
      .limit(50)

    @sent_submissions = Submission.where(email_status: "sent")
      .order(emailed_at: :desc)
      .limit(50)

    @failed_submissions = Submission.where(email_status: "failed")
      .order(created_at: :desc)
      .limit(50)

    # Summary stats
    @stats = {
      total: Submission.count,
      pending: Submission.where(email_status: "pending").count,
      sent: Submission.where(email_status: "sent").count,
      failed: Submission.where(email_status: "failed").count
    }
  end

  def retry
    submission = Submission.find(params[:id])

    # Retry sending the email
    begin
      SubmissionMailer.new_submission(submission).deliver_now
      submission.mark_as_emailed!
      flash[:success] = "Email sent successfully"
    rescue => e
      flash[:error] = "Failed to send email: #{e.message}"
      submission.mark_as_failed!
    end

    redirect_to email_queues_path
  end
end
