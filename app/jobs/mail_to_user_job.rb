include UserHelper
class MailToUserJob < ApplicationJob
    queue_as :default
  
    def perform(*args)
      begin
         # Defoulter user
         current_month_defoulters = defoulters().pluck(:email)

         # Manager
         #all_managers = managers_mail_ids().pluck(:email)
         
         new_joiners = new_joiners_group()

         # Remove managers from managers list and include them in to_user list
         #temp_user_holder = current_month_defoulters & all_managers

         # Get all New Joiners and match with defoulters if match found add in temp_new_users
         temp_new_users = current_month_defoulters & new_joiners
         
         # Remove Managers from to_users
         # current_month_defoulters.delete_if{|v|temp_user_holder.include?(v)}

         # Remove new Joiners from to_users_list
         current_month_defoulters.delete_if{|v|temp_new_users.include?(v)}

         # Remove Managers from cc_users, who is defoulter
         # all_managers.delete_if{|v|temp_user_holder.include?(v)}

         puts("    |- Mail to Defoulters sending on #{Time.now} ")
         
         # Comment below Assingments to start working with actula code.
         # current_month_defoulters = [
         #    {:id=>0,:email=>"khaled.khan@nitorinfotech.com"},
         #    {:id=>0,:email=>"bagwan.akib@nitorinfotech.com"},
         #    {:id=>0,:email=>"firebaseapp.akib@gmail.com"}
         #    ].pluck(:email)
         # all_managers = [
         #    {:id=>0,:email=>"bagwan.akib.64@gmail.com"},
         #    {:id=>0,:email=>"oneadsakib@gmail.com"}
         #    ].pluck(:email)
         # puts("All Managers : #{all_managers}")
         puts("\nAll defoulters : #{current_month_defoulters}")
         puts("\nAll new_joiners : #{temp_new_users}")

         # hot fix: 452 Too many recipients redmine
         all_managers = []
         defaulters_group = current_month_defoulters.in_groups_of(50)
          defaulters_group.each do |g|
            begin
              g = g.compact
              puts "++++"*15
              puts g              
              MailToUser.send_email_now(User.find(5), g, all_managers)
              puts g.count
              puts "++++"*15
            rescue Exception => e
              puts("\nDEFOULTERS MAIL Group [MAIL_TO_USER_JOB] #{Time.now} | Error occrd -> #{e}")
            end
          end

         # Send Mail to Defoulters
         # MailToUser.send_email_now(User.find(5), current_month_defoulters, all_managers)
         puts("--"*10)
         puts("Mail sent on #{Time.now} ")
         puts("--"*10)
      rescue => e
         puts("\nDEFOULTERS MAIL JOB [MAIL_TO_USER_JOB] #{Time.now} | Error occrd -> #{e}")
      end
    end
  end
  