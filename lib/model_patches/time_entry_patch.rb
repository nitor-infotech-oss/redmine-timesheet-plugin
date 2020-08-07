require_dependency 'time_entry'

module TimeEntryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      belongs_to :approval_status
      alias_method :editable_by?, :editable_by_added_persmission?
    end
  end

  module InstanceMethods
    def approval_status_details
      return self.approval_status.status
    end

    # Returns true if the time entry can be edited by usr, otherwise false
    def editable_by_added_persmission?(usr)
      visible?(usr) && (
        (((usr == user && usr.allowed_to?(:edit_own_time_entries, project)) || usr.allowed_to?(:edit_time_entries, project))) && ((usr.allowed_to?(:edit_approved_log_time_entries, project) || (self.approval_status_id != 2)))
      )
    end

    def deletable_by?(usr)
      usr.allowed_to?(:approve_log_time, project)
    end

  end
end

TimeEntry.send(:include, TimeEntryPatch)
