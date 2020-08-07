include WorkDayHelper
module UserHelper
  def managers?
    (User.current.roles.where name: "Manager").count >  0 
  end

  def admin?
    User.current.admin
  end

  def expected_time(to,from)
    first_day = to.to_date 												#Date.today.at_beginning_of_month
    end_day = from.to_date + 1											#Date.today.at_beginning_of_month.next_month
    working_days = first_day.business_days_until(end_day)
    # puts "---working days=--#{working_days}"
    # one_holiday =  working_days - 1 # 1jan hoilyday
    # puts ">>>>>one_holiday= #{one_holiday}"
    expected_hours = working_days * 8

  end

  def defoulters
    defoulters =[]
    expected = total_expected_hours
    initial_date = Time.parse('YYYY-MM-25').last_month
    end_date = Time.parse('YYYY-MM-24')

    users = User.where.not(:id=>[User.find(1),User.find(288),],:status=>3)
    users.each do |user|
      # hrs = TimeEntry.where(:user=>user).where("spent_on >= ? AND spent_on < ?", Time.now.beginning_of_month, Time.now.end_of_month).sum(:hours)
      hrs = TimeEntry.where(:user=>user).where("spent_on >= ? AND spent_on <= ?", (initial_date), (end_date) ).sum(:hours)
      if(user.email_address!=nil && (expected-hrs)>10)
        defoulters.push({id:user.id,firstname:user.firstname,:lastname=>user.lastname,hours:hrs,email:user.email_address.address})
      end
    end
    defoulters.uniq
  end

  # previous defaulters for month lock
  def month_lock_defaulters
    defoulters =[]
    beginning_date_of_last_month = Time.now.last_month.beginning_of_month
    end_date_of_last_month = Time.now.last_month.end_of_month
    expected_hrs = expected_time(beginning_date_of_last_month, end_date_of_last_month)
    puts "+++++++++++#{Time.now}++++++++++++++expected_hrs = +++#{expected_hrs}++++++"
    users =  User.where.not(:id=>[User.find(1),User.find(288),],:status=>3)

    users.each do |user|
      hrs = TimeEntry.where(:user=>user).where("spent_on >= ? AND spent_on <= ?", (beginning_date_of_last_month), (end_date_of_last_month) ).sum(:hours)

      if (user.email_address != nil && (expected_hrs > hrs))
        defoulters.push({id:user.id,firstname:user.firstname,:lastname=>user.lastname,hours:hrs,email:user.email_address.address})
      end
    end
    defoulters.uniq

  end

  def managers_mail_ids
    manager = []
    manager_mamber = MemberRole.where(:role_id=>Role.where(:name=>"Manager").last.id).joins(:member)
    manager_mamber.each do |project_manager|
      user = project_manager.member.user
      manager.push({:id=>user.id,:email=>user.email_address.address,:firstname=>user.firstname,:lastname=>user.lastname})
    end
    manager.uniq
  end
  
  # New joiners
  def new_joiners_group
    group_name = "New Joiners "
    new_joiners =[]
    new_joiners = EmailAddress
      .where(:user=>Group.where(:lastname=>group_name).last.users)
      .select("address")
      .pluck(:address)
    new_joiners=new_joiners.compact
    new_joiners.uniq
  end
end
