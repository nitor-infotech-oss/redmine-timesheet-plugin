class WeeklyReminderMailJob < ApplicationJob
queue_as :default

  def perform(*args)

    begin
      puts("--"*10)
      puts("Weekly Reminder - Mail sent on #{Time.now} Start")
      puts("--"*10)

      users = User.where(:status=>1)    # users = User.where(:id=> [242,5,243])

      users.each do |u|
        if u.email_address.present?
          user_mail = u.email_address.address
          begin
            puts  user_mail

            WeeklyReminderMail.send_email_now(u, user_mail)

          rescue Exception => e
            puts("\n Weekly Reminder mail [MAIL_TO_USER_JOB] #{Time.now} | Error occrd -> #{e}")
          end
        end
      end
      puts("--"*10)
      puts "Total count = #{users.count}"
      puts("Weekly Reminder - Mail sent on #{Time.now} END")
      puts("--"*10)
    rescue Exception => e
      puts("\n Weekly Reminder mail JOB [MAIL_TO_USER_JOB] #{Time.now} | Error occrd -> #{e}")
    end
  end
end
