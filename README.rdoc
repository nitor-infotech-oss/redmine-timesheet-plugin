# Redmine Plugin for Time Sheet Portal

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

# Highlights

- Nitor team built a web portal to provide a platform for people management and to record the amount of time employee spent on various tasks and projects
- It would help the organization to get insights on Billing and utilization ratio for every employee
- Design and development of the various modules of the portal and integrate with the application
- Development and deployment of the backend services for authentication and authorization, extract Master data of the employee from other systems
- Developed the timesheet portal by using Redmine timesheet plugin and modify the plugin to add an approval workflow
- Developed RBAC (Role-Based Access Control) module for Specific users with predefined roles had access to various projects as approvers and the flow also included rejection so that entries can be fixed and resubmitted for approval
- Developed several reports that exported the data, which is used by Finance for corporate financial reporting, also several internal reports developed for unit heads to review time logged filtered by month, users, projects
- Implementation of email scheduler to trigger scheduled emails

### Technical Dependencies Specifications

Redmine Version | 4.0.3. devel
--- | ---
Ruby Version | 2.5.1-p57 (2018-03-29) [x86_64-linux]
Rails Version | 5.2.3
Database Adapter  | PostgreSQL


### Set Up

##### Redmine Installation
- Get the Redmine source code by either downloading a packaged release or checking out the code repository.
- Copy config/database.yml.example to config/database.yml and edit this file in order to configure your database settings for "production" environment.
- You need to install Bundler first if you use Ruby 2.5.1:
```
    gem install bundler
```
- Then you can install all the gems required by Redmine using the following command:
```
    bundle install --without development test
```

##### Plugin Installation

To install the redmine-timesheet-plugin, execute the following commands from the root of your redmine directory, assuming that your RAILS_ENV enviroment variable is set to "production":
```
    git clone git://github.com/nitor-osss/redmine-timesheet-plugin.git plugins/redmine-timesheet-plugin
    bundle install
    rake redmine:plugins:migrate NAME=redmine-timesheet-plugin
```

More information on installing Redmine plugins can be found here: http://www.redmine.org/wiki/redmine/Plugins

After the plugin is installed and the db migration completed, you will need to restart Redmine for the plugin to be available.

##### Plugin Uninstallation
- rake redmine:plugins:migrate NAME=redmine-timesheet-plugin VERSION=0


### Getting Started with Plugin

- For importing timesheet plugin paste the codebase in plugin directory in Redmine core code.
- Once done, run the migration using below command:
```
    rake redmine:plugins:migrate
```
- Above command will populate the required tables for the timesheet plugin.
- A file init.rb act as an entry point for the plugin. All the dependencies have to be imported in this file to make them work. Please find below example of init.rb file for our plugin.


```
    # importing all dependencies at top
    require_dependency 'view_hooks/timelog_view_hook_listener'
    require_dependency 'controller_hooks/timelog_controller_hook_listener'
    require_dependency 'model_patches/time_entry_patch'
    require_dependency 'model_patches/time_entry_query_patch'
    # Plugin Metadata
    Redmine::Plugin.register :time_approval do
      name 'Time Approval plugin'
      author 'Team Nitor'
      description 'This is a plugin for Redmine'
      version '0.0.1'
      url 'http://example.com/path/to/plugin'
      author_url 'http://example.com/about'
    end
```
Note: The application has to be restarted every time changes are made to the plugin.
##### Model Patches
- The models used in the Redmine plugin can be extended by applying patches. We are storing these patches at location /plugins/time_approval/lib/model_patches/.
- We can add custom methods, relationships/associations to the existing models using model patches.
- Below is an example of model patch –
```
    require_dependency 'time_entry'

    module TimeEntryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          belongs_to :approval_status
        end
      end
      module InstanceMethods
        def approval_status_details
          return self.approval_status.status
        end
      end
    end
    TimeEntry.send(:include, TimeEntryPatch)
```
- In above patch we are adding an association approval_status and adding an instance method approval_status_details to existing model.

##### Controller Hooks
- There are hooks left in redmine core to allow execution of customised code. We can use these hooks to place the business logic as per the requirements in the hooks.
- Below is an example of controller action where hook is placed -
```
  def update
    @time_entry.safe_attributes = params[:time_entry]
    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })
    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default project_time_entries_path(@time_entry.project)
        }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end
```

- Below is an example of controller hook listener -

```
    class TimelogControllerHookListener < Redmine::Hook::ViewListener
      def controller_timelog_edit_before_save(context={})
        context[:time_entry].approval_status_id = context[:params][:time_entry][:approval_status]
      end
    end
```

- The line call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry }) from controller action calls the hook listener customised in plugin and executes the code from specified method in hook listener file.

##### View Hooks
- Similar to controller hooks there are hooks present in the views. When custom html is to be embedded in the existing Redmine views, we leverage the view hooks present in the existing Redmine core code. We can write our custom html view files and render it in the hooks present in Redmine core views.
Refer following code to understand how view hooks

```
    class TimelogViewHookListener < Redmine::Hook::ViewListener
      # renders the partial view from /plugins/time_approval/views/context_menus/
      render_on :view_time_entries_context_menu_end,
                :partial => 'approval_action_menu'
    end
```
##### New Models/Views/Controllers/Migrations

We can create new components in the way we would create for any rails app.  When a plugin in integrated with Redmine core, it incorporates all the changes from new components from plugin.

### Further References
- http://www.redmine.org/projects/redmine/wiki/plugin_tutorial
- https://www.agiratech.com/redmine-plugin-development/
- https://jkraemer.net/2015/11/how-to-create-a-redmine-plugin
- http://www.redmine.org/projects/redmine/wiki/Plugin_Internals
