class ViewMyAccountHookListener < Redmine::Hook::ViewListener
  render_on :view_my_account,
            :partial => 'account_view'
end
