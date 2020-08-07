require_dependency 'user'

module UserPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable

      alias_method :check_password?, :update_emp_id
    end
  end

  module InstanceMethods
    # update emp_id its nil or shpuld authenticated
    def update_emp_id(clear_password)
      if auth_source_id.present?
        user = auth_source.authenticate(self.login, clear_password)

        if !self.employee_id && user.present?
          self.employee_id = user[:employee_id]
          self.save
        end
        user
      else
        User.hash_password("#{salt}#{User.hash_password clear_password}") == hashed_password
      end
    end
  end
end

User.send(:include, UserPatch)
