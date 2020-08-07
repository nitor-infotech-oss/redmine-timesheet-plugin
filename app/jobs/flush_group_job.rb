# include UserHelper
class FlushGroupJob < ApplicationJob
  # queue_as :default

  def perform(*args)
    begin
      puts ">>>>>>>>>>>>>>Flush data>>>>>>>>>>"
      user = User.find(309)
      groups = Group.where(:lastname => ["New Joiners ", "Month Unlock"])

        groups.each do |g|
          if g.users.present?
            g.users.delete_all

            FlushGroupMail.send_email_now(user , g)
            puts "--#{g.lastname}----Succfully flush-------"
          end
        end

    rescue => e
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> faild Flush data"

       puts("\n Flush group data #{Time.now} | Error occrd -> #{e}")
    end
  end
end
