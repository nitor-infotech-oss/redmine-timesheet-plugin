require 'mailer'

class WeeklyReminderMail < Mailer
  def send_weekly_reminder_mail(user, to_user)
    @user = user
    
      mail :to => to_user,
      :subject => "Timesheet - Reminder for time booking."
  end

  def self.send_email_now(user, g)
    raise_delivery_errors_was = self.raise_delivery_errors
    self.raise_delivery_errors = true
    send_weekly_reminder_mail(user, g).deliver_now
  ensure
    self.raise_delivery_errors = raise_delivery_errors_was
  end
end
