require_dependency 'time_entry_query'

module TimeEntryQueryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      alias_method :available_columns_without_extra, :available_columns
      alias_method :available_columns, :available_columns_with_extra_columns
    end
  end

  module InstanceMethods
    def available_columns_with_extra_columns
      base_columns = available_columns_without_extra
      base_columns.push(QueryColumn.new(:approval_status_details)) unless base_columns.detect{ |c| c.name == :approval_status_details }
      return base_columns
    end
  end
end

TimeEntryQuery.send(:include, TimeEntryQueryPatch)
