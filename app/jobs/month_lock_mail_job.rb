include UserHelper
class MonthLockMailJob < ApplicationJob
    queue_as :default
  
    def perform(*args)
      begin
        previous_month_defoulters = month_lock_defaulters.pluck(:email)

        defaulters_group =  previous_month_defoulters.in_groups_of(50)

          defaulters_group.each do |g|
            begin
              g = g.compact
              puts "++++"*15
              puts g              
              MonthLockMail.send_email_now(User.find(5), g)
              puts g.count
              puts "++++"*15
            rescue Exception => e
              puts("\n Month Lock DEFOULTERS MAIL Group [MAIL_TO_USER_JOB] #{Time.now} | Error occrd -> #{e}")
            end
          end

         puts("--"*10)
         puts("Mail sent on #{Time.now} ")
         puts("--"*10)
      rescue => e
         puts("\n Month Lock DEFOULTERS MAIL JOB [MAIL_TO_USER_JOB] #{Time.now} | Error occrd -> #{e}")
      end
    end
  end
