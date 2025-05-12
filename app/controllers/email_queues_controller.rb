class EmailQueuesController < ApplicationController
  before_action :require_admin

  def index
    # Get submissions by email status
    @pending_submissions = Submission.where(email_status: "pending").order(created_at: :desc).limit(50)
    @sent_submissions = Submission.where(email_status: "sent").order(emailed_at: :desc).limit(50)
    @failed_submissions = Submission.where(email_status: "failed").order(created_at: :desc).limit(50)

    # Summary stats
    @stats = {
      total: Submission.count,
      pending: @pending_submissions.size,
      sent: @sent_submissions.size,
      failed: @failed_submissions.size
    }
  end

  def retry
    submission = Submission.find(params[:id])

    # Retry sending the email
    begin
      SubmissionMailer.new_submission(submission).deliver_later
      submission.update(email_status: "pending")
      flash[:success] = "Email queued for retry"
    rescue => e
      flash[:error] = "Failed to queue email: #{e.message}"
    end

    redirect_to email_queues_path
  end
end
