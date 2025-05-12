module SolidQueue
  class Job < ApplicationRecord
    self.table_name = "solid_queue_jobs"
    
    has_one :failed_execution, class_name: "SolidQueue::FailedExecution", foreign_key: :job_id
    has_one :claimed_execution, class_name: "SolidQueue::ClaimedExecution", foreign_key: :job_id
    has_one :ready_execution, class_name: "SolidQueue::ReadyExecution", foreign_key: :job_id
    has_one :scheduled_execution, class_name: "SolidQueue::ScheduledExecution", foreign_key: :job_id
    
    scope :pending, -> { where(finished_at: nil) }
    scope :completed, -> { where.not(finished_at: nil) }
    scope :failed, -> { joins(:failed_execution) }
    scope :mailer_jobs, -> { where(class_name: "ActionMailer::MailDeliveryJob") }
    
    def failed?
      failed_execution.present?
    end
    
    def pending?
      finished_at.nil?
    end
    
    def completed?
      finished_at.present?
    end
    
    def status
      if failed?
        "failed"
      elsif completed?
        "completed"
      elsif scheduled_at && scheduled_at > Time.current
        "scheduled"
      else
        "pending"
      end
    end
  end
end