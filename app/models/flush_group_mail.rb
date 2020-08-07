require 'mailer'

class FlushGroupMail < Mailer
  def send_flushing_group_mail(user, g)
    @group = g
    to_user = user.email_address.address
    
      mail :to => to_user,
      :subject => "Flushing Group - #{Time.now.strftime('%d %B %Y')}"
  end

  def self.send_email_now(user, g)
    raise_delivery_errors_was = self.raise_delivery_errors
    self.raise_delivery_errors = true
    send_flushing_group_mail(user, g).deliver_now
  ensure
    self.raise_delivery_errors = raise_delivery_errors_was
  end
end
