class CustomReportsController < ApplicationController
  before_action :require_admin
  # before_action :expected_time, only: [:datewise_reports, :defaulters_report] #except: :index

	def index
	end
	def datewise_reports
    to_date = params['user']['to_date']
    from_date = params['user']['from_date']

    if !to_date.empty? && !from_date.empty?
      et = expected_time(from_date, to_date)

	    @connection = ActiveRecord::Base.connection
	    query = "
			select 
			(select value from custom_values where custom_field_id=3/*EMPID*/ and customized_id=u.id) as Old_Employee_id,
			u.employee_id as employee_id,
			CONCAT(u.firstname,' ',u.lastname) as Resource_name,
			(select CONCAT(users.firstname,' ',users.lastname) from users,member_roles,members where users.id=members.user_id
			and member_roles.member_id=members.id
			and members.project_id=p.id
			and member_roles.role_id=3 LIMIT 1) as Manager,p.name as Project_name,
		/*	(select value from custom_values where custom_field_id=1/*DU*/ and customized_id=(CASE WHEN p.parent_id > 0 THEN p.parent_id else p.id END)) as DU, */

			(select value from custom_values where custom_field_id=1/*DU*/ and customized_id= p.id) as DU,
			(select value from custom_values where custom_field_id=4/*Clint name*/ and customized_id=(CASE WHEN p.parent_id > 0 THEN p.parent_id else p.id END)) as Client_name,

			sum(CASE WHEN t.hours > 0 THEN t.hours else 0 END) as Total_Time_Logged,
			sum(CASE WHEN t.activity_id = 8 THEN t.hours else 0 END) as Time_logged_Task,
			sum(CASE WHEN t.activity_id = 9 THEN t.hours else 0 END) as Time_logged_Leave,
			sum(CASE WHEN t.approval_status_id =2 THEN t.hours else 0 END) as Approved,
			sum(CASE WHEN t.approval_status_id =1 THEN t.hours else 0 END) as Not_Approved,
			'#{et}' as EXPECTED_TIME_LOG
			from users u 
			left join time_entries t on u.id = t.user_id and t.spent_on >='#{from_date}'::date and t.spent_on <= '#{to_date}'::date
			left join projects p on p.id= t.project_id 
			where u.id not in (1,2,3,4) and u.status != 3
			GROUP BY Resource_name,p.name,u.id,p.id
			ORDER BY p.name ASC,Resource_name ASC"
	    @result = @connection.exec_query(query)

	  else
	  	render_error_message
	  end
	end

	def not_approved
		to_date = params['user']['to_date']
    from_date = params['user']['from_date']
		if !to_date.empty? && !from_date.empty?
	    @connection = ActiveRecord::Base.connection
	    query = "
			select 
			(select value from custom_values where custom_field_id=3/*EMPID*/ and customized_id=u.id) as Old_Employee_id,
			u.employee_id as employee_id,
			CONCAT(u.firstname,' ',u.lastname) as Resource_name,
			(select CONCAT(users.firstname,' ',users.lastname) from users,member_roles,members where users.id=members.user_id
			and member_roles.member_id=members.id
			and members.project_id=p.id
			and member_roles.role_id=3 LIMIT 1) as Manager,p.name as Project_name,
		/*	(select value from custom_values where custom_field_id=1/*DU*/ and customized_id= (CASE WHEN p.parent_id > 0 THEN p.parent_id else p.id END)) as DU, */

			(select value from custom_values where custom_field_id=1/*DU*/ and customized_id= p.id) as DU,

			(select value from custom_values where custom_field_id=5/*DOJ*/ and customized_id=u.id) as Date_of_joining,
			sum(CASE WHEN t.hours > 0 THEN t.hours else 0 END) as Total_Time_Logged,
			sum(CASE WHEN t.approval_status_id = 1 THEN t.hours else 0 END) as Not_Approved
			from users u 
			left join time_entries t on u.id = t.user_id and t.spent_on >='#{from_date}'::date and t.spent_on <= '#{to_date}'::date
			left join projects p on p.id= t.project_id 
			where u.id not in (1,2,3,4)
			and u.status != 3
			GROUP BY Resource_name,p.name,u.id,p.id
			ORDER BY Project_name ASC, Resource_name ASC"
			@result = @connection.exec_query(query)
		else
			render_error_message
	  end
	end

	def defaulters_report
		to_date = params['user']['to_date']
    from_date = params['user']['from_date']
  	if !to_date.empty? && !from_date.empty?
      et = expected_time(from_date, to_date)

		  @connection = ActiveRecord::Base.connection
		  query = "
			select
			(select value from custom_values where custom_field_id=3/*EMPID*/ and customized_id=u.id) as Old_Employee_id,
			u.employee_id as employee_id,
			CONCAT(u.firstname,' ',u.lastname) as resource_name,
			ARRAY_TO_STRING(ARRAY_AGG(DISTINCT (
			select ARRAY_TO_STRING(ARRAY_AGG(DISTINCT ( select CONCAT(users.firstname,' ',users.lastname) from users,member_roles,members where users.id=members.user_id
			and member_roles.member_id=members.id
			and members.project_id=projects.id 
			and member_roles.role_id=3 LIMIT 1 )), ', ')
			from time_entries,projects,users
			where time_entries.user_id = users.id
			and time_entries.project_id= projects.id
			and users.id=u.id 
			and time_entries.spent_on >='#{from_date}'::date and time_entries.spent_on <= '#{to_date}'::date
			LIMIT 1
			)), ', ') as MANAGER,
			ARRAY_TO_STRING(ARRAY_AGG(DISTINCT (
			select ARRAY_TO_STRING(ARRAY_AGG(DISTINCT (projects.name)),',') from 
			users,time_entries,projects where users.id=u.id
			and users.id=time_entries.user_id
			and projects.id = time_entries.project_id
			and time_entries.spent_on >='#{from_date}'::date and time_entries.spent_on <= '#{to_date}'::date
			)), ', ') as PROJECT_NAME,
			(select value from custom_values where custom_field_id=5/*DOJ*/ and customized_id=u.id) as Date_of_joining,
			sum(CASE WHEN t.hours > 0 THEN t.hours else 0 END) as Actual_Log,
			'#{et}' as EXPECTED_TIME_LOG,
			(CASE WHEN ('#{et}' - sum(CASE WHEN t.hours > 0 THEN t.hours else 0 END))>10 then concat('#{et}' - sum(CASE WHEN t.hours > 0 THEN t.hours else 0 END),'') else 'No' end) as Gap 
			from users u full join time_entries t on t.user_id = u.id and t.spent_on >='#{from_date}'::date and t.spent_on <= '#{to_date}'::date
			where u.status != 3 and u.id not in (1,2,3,4) and u.type != 'Group'
			GROUP BY u.id
			order by project_name DESC,resource_name ASC"
			@result = @connection.exec_query(query)
			
			arr_result = @result.to_a
			@result.each do |row| 
				if row["gap"] == "No"
					arr_result.delete(row)
				end
			end
			@result = arr_result
		else
			render_error_message
	  end
	end

	def managers_report
		to_date = params['user']['to_date']
    from_date = params['user']['from_date']
  	if !to_date.empty? && !from_date.empty?
		  @connection = ActiveRecord::Base.connection
		  query = "
			select 
			(select value from custom_values where custom_field_id=3 and customized_id=u.id) as Old_Employee_id,
			u.employee_id as employee_id,
			CONCAT(u.firstname,' ',u.lastname) as Manager_Name, p.name as Project_Name,
		/*	(select value from custom_values where custom_field_id=1 and customized_id=u.id) as DU, */
			sum(CASE WHEN t.hours > 0 THEN t.hours else 0 END) as Total_Time_Logged,
			sum(CASE WHEN t.activity_id = 8 THEN t.hours else 0 END) as Time_logged_Task,
			sum(CASE WHEN t.activity_id = 9 THEN t.hours else 0 END) as Time_logged_Leave,
			sum(CASE WHEN t.approval_status_id =2 THEN t.hours else 0 END) as Approved,
			sum(CASE WHEN t.approval_status_id =1 THEN t.hours else 0 END) as Not_Approved 
			from 
			users u inner join time_entries t on t.user_id = u.id and t.spent_on >='#{from_date}'::date and t.spent_on <= '#{to_date}'::date
			inner join projects p on p.id= t.project_id
			where u.id = ANY (select DISTINCT uu.id from 
			users uu inner join members mm on uu.id=mm.user_id
			inner join member_roles mr on mr.member_id=mm.id and mr.role_id=3
			inner join projects pp on mm.project_id=pp.id)
			group by p.name,Manager_Name,u.id
			order by Manager_Name ASC, Project_Name ASC"
			@result = @connection.exec_query(query)
			
		else
			render_error_message
	  end
	end

	def active_projects_report
		@projects =  Project.all
	end

	private

	def render_error_message
	  render_error({:message => "Please select the date", :status => 403})
	end
end
