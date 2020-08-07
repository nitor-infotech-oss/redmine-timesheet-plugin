require 'mailer'

class MailToUser < Mailer
  def send_mail(user,to_users, cc_users)
    @user = user
    @time_entry = "No time entry"
    if cc_users.size!=0
      mail :to => to_users, :cc=>cc_users,
      :subject => "Timesheet Defaulters of #{Time.now.strftime('%B %Y')}"
    else
      mail :to => to_users,
      :subject => "Timesheet Defaulters of #{Time.now.strftime('%B %Y')}"
    end

    #, #{Time.now.strftime('%a %d %B %Y | %l:%M %p')}
  end

  def self.send_email_now(user, defoulter,managers)
    raise_delivery_errors_was = self.raise_delivery_errors
    self.raise_delivery_errors = true
    send_mail(user,defoulter, managers).deliver_now
  ensure
    self.raise_delivery_errors = raise_delivery_errors_was
  end
end
