require_dependency 'auth_source_ldap'

module AuthSourceLdapPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable

      alias_method :search_attributes, :search_attributes_with_emp_id
      alias_method :get_user_attributes_from_ldap_entry, :get_user_attributes_from_ldap_with_emp_id
    end
  end

  module InstanceMethods

    # override this method to get new attributes(emp_id) from LDAP entry
    def get_user_attributes_from_ldap_with_emp_id(entry)
      {
       :dn => entry.dn,
       :firstname => AuthSourceLdap.get_attr(entry, self.attr_firstname),
       :lastname => AuthSourceLdap.get_attr(entry, self.attr_lastname),
       :mail => AuthSourceLdap.get_attr(entry, self.attr_mail),
       :auth_source_id => self.id,
       :employee_id => AuthSourceLdap.get_attr(entry, self.employeeid)

      }
    end

    def search_attributes_with_emp_id
      if onthefly_register?
        ['dn', self.attr_firstname, self.attr_lastname, self.attr_mail, "employeeID" ]
      else
        ['dn']
      end
    end

  end
end

AuthSourceLdap.send(:include, AuthSourceLdapPatch)
