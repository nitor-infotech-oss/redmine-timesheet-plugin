require_dependency 'timelog_controller'
include UserHelper

module TimeLogControllerPatch
  def self.included(base) # :nodoc:
    base.send(:include, MonthLockModule)

    base.class_eval do
      unloadable
      alias_method :original_index_method, :create # modify some_method method by adding your_action action
      alias_method :create, :month_lock # modify some_method method by adding your_action action

      alias_method :index,:index_patch
      alias_method :report,:report_patch
    end
  end

  module MonthLockModule
    def month_lock
      @current_user = User.current

      custom_month_lock = CustomItems.first.month_lock
      spent_date = params['time_entry']['spent_on'].to_date
      puts "==========Month unlock 3days = #{((1.month.ago.month == spent_date.month) && (Time.now.day <= 3))}"

      # if  custom_month_lock || Time.now.month == spent_date.month || @current_user.admin? || unlock_month_group || ((1.month.ago.month == spent_date.month) && (Time.now.day <= 5))
      if  custom_month_lock || Time.now.month == spent_date.month || @current_user.admin? || unlock_month_group || ((Time.now.month - 1 == spent_date.month) && (Time.now.day <= 5))
 
        original_index_method
      else
        flash[:error] = l(:month_lock, user_name: @current_user.name)
        redirect_to :back
        return
      end
    end

    def unlock_month_group
      arr_group = []
      @current_user.groups.each do |user_groups|
        arr_group << user_groups.lastname
      end
      arr_group = arr_group.include? "Month Unlock"
      return arr_group
    end

    def index_patch
      retrieve_time_entry_query
      if User.current.admin? || managers?
        scope = time_entry_scope.
        preload(:issue => [:project, :tracker, :status, :assigned_to, :priority]).
        preload(:project, :user)
      else
        scope = time_entry_scope.
        preload(:issue => [:project, :tracker, :status, :assigned_to, :priority]).
        preload(:project, :user).where("#{TimeEntry.table_name}.user_id":User.current.id)
      end

      respond_to do |format|
        format.html {
          @entry_count = scope.count
          @entry_pages = Redmine::Pagination::Paginator.new @entry_count, per_page_option, params['page']
          @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a

          render :layout => !request.xhr?
        }
        format.api  {
          @entry_count = scope.count
          @offset, @limit = api_offset_and_limit
          @entries = scope.offset(@offset).limit(@limit).preload(:custom_values => :custom_field).to_a
        }
        format.atom {
          entries = scope.limit(Setting.feeds_limit.to_i).reorder("#{TimeEntry.table_name}.created_on DESC").to_a
          render_feed(entries, :title => l(:label_spent_time))
        }
        format.csv {
          # Export all entries
          @entries = scope.to_a
          send_data(query_to_csv(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'timelog.csv')
        }
      end
    end

    def report_patch
      retrieve_time_entry_query
      if User.current.admin? || managers?
        scope = time_entry_scope
      else
        scope = time_entry_scope.where("user_id":User.current.id)
      end

      @report = Redmine::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], scope)

      respond_to do |format|
        format.html { render :layout => !request.xhr? }
        format.csv  { send_data(report_to_csv(@report), :type => 'text/csv; header=present', :filename => 'timelog.csv') }
      end
    end
  end
end

TimelogController.send :include, TimeLogControllerPatch
