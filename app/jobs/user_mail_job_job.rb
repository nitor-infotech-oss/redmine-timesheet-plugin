class UserMailJobJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts("Start Job! Get Bulk data and send to users")
    # Here the query come 
    puts("\n--->Send Single Mail to user"*1)
    # users.each do |user|
    #   if(user.email_address!=nil)
    #     MailToUserJob.perform_now(user.email_address.address)
    #   end
    # end
    MailToUserJob.perform_now()
  end
end
