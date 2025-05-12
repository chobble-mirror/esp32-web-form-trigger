module SolidQueue
  class ScheduledExecution < ApplicationRecord
    self.table_name = "solid_queue_scheduled_executions"
    
    belongs_to :job, class_name: "SolidQueue::Job", foreign_key: :job_id
  end
end