require 'mailer'

class NotificationMailer < Mailer
  def approval_action_email(user, time_entry)
    @user = user
    @time_entry = time_entry
    mail :to => user,
      :subject => 'Nitor Timesheet Portal - Timesheet Rejected.'
  end

  def self.send_email_now(user, time_entry)
    raise_delivery_errors_was = self.raise_delivery_errors
    self.raise_delivery_errors = true
    approval_action_email(user, time_entry).deliver_now
  ensure
    self.raise_delivery_errors = raise_delivery_errors_was
  end

end
