class CustomPageController < ApplicationController
  before_action :require_admin

  def index
    @custom_item = CustomItems.first
  end

  # for month lock update
  def update
    @custom_item = CustomItems.first
    @custom_item.update(month_lock: params[:month_lock])

      if @custom_item.month_lock
        flash.now[:notice] = l(:admin_month_unlock)
      else
        flash.now[:error] = l(:admin_month_lock)
      end

      render :action => 'index'
  end

  def update_working_day
    @custom_item = CustomItems.first
    @custom_item.update(working_day: params[:working_day])
      flash.now[:notice] = l(:update_working_day)

      render :action => 'index'

  end

end
