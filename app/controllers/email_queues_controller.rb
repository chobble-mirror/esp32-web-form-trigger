class EmailQueuesController < ApplicationController
  before_action :require_admin

  def index
    # Get jobs related to emails
    @pending_jobs = SolidQueue::Job.where(class_name: "ActionMailer::MailDeliveryJob")
      .where(finished_at: nil)
      .order(created_at: :desc)

    @completed_jobs = SolidQueue::Job.where(class_name: "ActionMailer::MailDeliveryJob")
      .where.not(finished_at: nil)
      .order(finished_at: :desc)
      .limit(20)

    # Find jobs with errors
    @failed_jobs = SolidQueue::FailedExecution.includes(:job)
      .where(job: {class_name: "ActionMailer::MailDeliveryJob"})
      .order(created_at: :desc)
      .limit(20)

    # Get submissions with failed email status
    @failed_submissions = Submission.where(email_status: "failed")
      .order(created_at: :desc)
      .limit(20)
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
