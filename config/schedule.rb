#set :environment, "development"
set :environment, "production"
set :output, "#{Whenever.path}/log/whenever.log"
set :job_template, nil
job_type :runner, "cd :path/../../ && bundle exec rails runner -e :environment ':task' :output"
# bundle exec rails runner -e development 'UserMailJobJob.perform_later()
# env :PATH, ENV['PATH']
# env :GEM_PATH, ENV['GEM_PATH']

# friday reminder
every :friday, at: '10.00am' do
    env :PATH, ENV['PATH']
    runner "WeeklyReminderMailJob.perform_now"
end

# min hour day_of_month month day_of_week
every '10 10 2 * *' do
    # This Mail will be sent at 26th day of the month at 9:35 AM
    env :PATH, ENV['PATH']
    runner "MonthLockMailJob.perform_now"
end

# min hour day_of_month month day_of_week
every '15 9 25 * *' do
    # This Mail will be sent at 26th day of the month at 9:35 AM
    env :PATH, ENV['PATH']
    runner "UserMailJobJob.perform_now"
end

every '10 10 27 * *' do
    # This Mail will be sent at 27th day of the month at 9:35 AM
    env :PATH, ENV['PATH']
    runner "UserMailJobJob.perform_now"
end

every '30 10 29 * *' do
    # This Mail will be sent at 27th day of the month at 9:35 AM
    env :PATH, ENV['PATH']
    runner "UserMailJobJob.perform_now"
end


every '00 17 * * *' do
    # This Mail will be sent at 27th day of the month at 9:35 AM
    env :PATH, ENV['PATH']
    runner "FlushGroupJob.perform_now"
end

# You also can use following:
# 1.minute 1.day 1.week 1.month 1.year is also supported
# command "echo 'here you can use raw cron syntax too'"
