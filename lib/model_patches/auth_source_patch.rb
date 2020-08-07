require_dependency 'auth_source'

module AuthSourcePatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable

      attribute :employeeid, :string, default: :employeeid

      # alias_method :old_method, :new_method
    end
  end

  module InstanceMethods
    def new_method
    end
  end
end

AuthSource.send(:include, AuthSourcePatch)
