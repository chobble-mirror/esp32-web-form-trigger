module SolidQueue
  class ClaimedExecution < ApplicationRecord
    self.table_name = "solid_queue_claimed_executions"
    
    belongs_to :job, class_name: "SolidQueue::Job", foreign_key: :job_id
  end
end