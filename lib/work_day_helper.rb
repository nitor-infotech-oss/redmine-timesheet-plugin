module WorkDayHelper
    
    def total_working
        total_sundays = (Date.today.at_beginning_of_month..Date.today.end_of_month).group_by(&:wday)[0].count
        total_saturday = (Date.today.at_beginning_of_month..Date.today.end_of_month).group_by(&:wday)[6].count
        total_days=Time.days_in_month(Time.now.month, Time.now.year)
        (total_days-total_sundays)-total_saturday
    end

    def total_expected_hours
        #total_working * 8 # 8 hr total working in day 

        # Hot Fix for November month : 19 working days
        # 21 * 8
        working_days = CustomItems.first.working_day 
        working_days * 8
    end
end
