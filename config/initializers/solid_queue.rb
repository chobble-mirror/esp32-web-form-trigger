# Configure SolidQueue as the ActiveJob queue adapter
Rails.application.config.active_job.queue_adapter = :solid_queue

# The serializer option is not supported in SolidQueue
# Removing the serializer configuration as it's causing errors
