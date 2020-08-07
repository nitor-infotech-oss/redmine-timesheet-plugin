require 'mailer'

class MonthLockMail < Mailer
  def send_month_lock_mail(user,to_users)
    @user = user
    
      mail :to => to_users,
      :subject => "Timesheet Portal Month Lock!"
  end

  def self.send_email_now(user, defoulter)
    raise_delivery_errors_was = self.raise_delivery_errors
    self.raise_delivery_errors = true
    send_month_lock_mail(user,defoulter).deliver_now
  ensure
    self.raise_delivery_errors = raise_delivery_errors_was
  end
end
