# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'customreports', :to => 'custom_reports#index'
post 'customreports/datewise_reports', :to => 'custom_reports#datewise_reports'

post 'customreports/not_approved', :to => 'custom_reports#not_approved'

post 'customreports/defaulters_report', :to => 'custom_reports#defaulters_report'

post 'customreports/managers_report', :to => 'custom_reports#managers_report'

post 'customreports/active_projects_report', :to => 'custom_reports#active_projects_report'

get 'custompage', :to => 'custom_page#index'

post 'custompage/update', :to => 'custom_page#update'

post 'custompage/update_working_day', :to => 'custom_page#update_working_day'

