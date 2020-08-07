require_dependency 'view_hooks/timelog_view_hook_listener'
require_dependency 'view_hooks/view_my_account_hook_listener'

require_dependency 'controller_hooks/timelog_controller_hook_listener'

require_dependency 'model_patches/time_entry_patch'
require_dependency 'model_patches/time_entry_query_patch'
require_dependency 'model_patches/auth_source_patch'
require_dependency 'model_patches/auth_source_ldap_patch'
require_dependency 'model_patches/user_patch'

require 'time_log_controller_patch'
require 'account_controller_patch'

require 'queries_helper_patch.rb'

require 'rails/all'
Bundler.require(*Rails.groups)


Redmine::Plugin.register :time_approval do
  name 'Time Approval plugin'
  author 'Team Nitor'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/nitor-infotech-oss/redmine-timesheet-plugin'
  author_url 'https://www.nitorinfotech.com'

  menu  :top_menu   , :customreports, { :controller => 'custom_reports', :action => 'index' }, :caption => 'Reports',:if => Proc.new { User.current.admin? }, :last => true

  menu  :top_menu   , :custompage, { :controller => 'custom_page', :action => 'index' }, :caption => 'Custom',:if => Proc.new { User.current.admin? }, :last => true
  # Delayed Job set the queue_adapter configration
  Rails.application.config.active_job.queue_adapter = :delayed_job

  # Delayed::Worker.sleep_delay = 60

  # delay_jobs while application is in testing or development
  Delayed::Worker.delay_jobs = false

  # default behavior is to read 5 jobs from the queue when finding an available job.
  # Delayed::Worker.read_ahead

  # The default Worker.max_attempts is 3.
  Delayed::Worker.max_attempts = 1

  # The default Worker.max_run_time is 5.minutes.
  Delayed::Worker.max_run_time = 5.minutes
end

# Customize Permissions
Redmine::Plugin.register :time_approval do
  Redmine::AccessControl.map do |map|
    map.project_module :time_tracking do |map|
      map.permission :approve_log_time, {:approval => [:change_status, :bulk_edit]}, :require => :member
    end
  end
end

RedmineApp::Application.routes.append do
  resources :time_entries, :controller => 'approval', :except => :destroy do
    collection do
      post 'change_status'
    end
  end
end

Recaptcha.configure do |config|
  config.site_key   = '6Le1uwEVAAAAAKe_tFrO3y_SnP-SBEOtj46NVZSN'
  config.secret_key  ='6Le1uwEVAAAAAHR45r_hjEOIgq8QYPFclUt7XIKV'
end

RedmineApp::Application.routes.prepend do
  get 'author', :to => 'admin#index'
  get 'author/projects', :to => 'admin#projects'
  get 'author/plugins', :to => 'admin#plugins'
  get 'author/info', :to => 'admin#info'
  # post 'author/test_email', :to => 'admin#test_email', :as => 'test_email'
  post 'author/default_configuration', :to => 'admin#default_configuration'
end
