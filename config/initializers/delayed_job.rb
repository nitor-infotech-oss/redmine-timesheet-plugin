
#   Rails.application.initialize!
  

#  Delayed Job set the queue_adapter configration
#   Rails.application.config.active_job.queue_adapter = :delayed_job
# Delayed::Worker.sleep_delay = 60

# delay_jobs while application is in testing or development
Delayed::Worker.delay_jobs = false

# default behavior is to read 5 jobs from the queue when finding an available job.
# Delayed::Worker.read_ahead

# The default Worker.max_attempts is 3.
Delayed::Worker.max_attempts = 1

# The default Worker.max_run_time is 5.minutes.
Delayed::Worker.max_run_time = 5.minutes
# Delayed::Worker.logger = Logger.new("#{Whenever.path}/log/delayed_job.log")
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'dj.log'))
Delayed::Worker.default_queue_name = 'nitor_mailer_job'