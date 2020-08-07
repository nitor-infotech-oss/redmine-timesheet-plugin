class ApprovalController < ApplicationController
  menu_item :time_entries

  before_action :find_time_entries, :only => [:change_status]
  before_action :authorize, :only => [:change_status]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :issues
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper


  def change_status
    attributes = parse_params_for_bulk_update(params[:time_entry])
    unsaved_time_entries = []
    saved_time_entries = []
    @time_entries.each do |time_entry|
      time_entry.reload
      time_entry.safe_attributes = attributes
      time_entry.approval_status_id = params[:time_entry][:approval_status]
      if(time_entry.approval_status_id == 3)
        saved_time_entries << time_entry
        send_email = NotificationMailer.send_email_now(time_entry.user, time_entry)
        time_entry.destroy
      else
        if time_entry.save
          saved_time_entries << time_entry
        else
          unsaved_time_entries << time_entry
        end
      end
    end

    if unsaved_time_entries.empty?
      flash[:notice] = l(:notice_successful_update) unless saved_time_entries.empty?
      redirect_back_or_default project_time_entries_path(@projects.first)
    else
      @saved_time_entries = @time_entries
      @unsaved_time_entries = unsaved_time_entries
      @time_entries = TimeEntry.where(:id => unsaved_time_entries.map(&:id)).
        preload(:project => :time_entry_activities).
        preload(:user).to_a
      bulk_edit
      render :action => 'bulk_edit'
    end
  end



private

  def find_time_entries
    @time_entries = TimeEntry.where(:id => params[:id] || params[:ids]).
      preload(:project => :time_entry_activities).
      preload(:user).to_a

    raise ActiveRecord::RecordNotFound if @time_entries.empty?
    raise Unauthorized unless @time_entries.all? {|t| t.editable_by?(User.current)} || @time_entries.all? {|t| t.deletable_by?(User.current)}
    @projects = @time_entries.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
