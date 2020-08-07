class TimelogViewHookListener < Redmine::Hook::ViewListener

  render_on :view_time_entries_context_menu_end,
            :partial => 'approval_action_menu'

  def view_layouts_base_html_head(context)
    javascript_include_tag(:view_time_entries_context_menu_end, :plugin => 'time_approval')
    stylesheet_link_tag(:view_time_entries_context_menu_end, :plugin => 'time_approval')
  end

  # def view_time_entries_context_menu_end(context = {})
  # end

  def view_timelog_edit_form_bottom(context)
    javascript_include_tag(:view_timelog_edit_form_bottom, :plugin => 'time_approval')
  end

  def view_layouts_base_body_bottom(context)
    javascript_include_tag(:view_layouts_base_body_bottom, :plugin => 'time_approval')
  end

end
