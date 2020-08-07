require 'redmine/export/csv'
require_dependency 'queries_helper'
module QueriesHelperPatch
  def self.included(base) 
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method :filters_options_for_select, :filters_options_for_select_patch
      alias_method :render_query_totals, :render_query_totals_patch
    end
  end

  module InstanceMethods
  
    include ApplicationHelper
   
    def filters_options_for_select_patch(query)
      ungrouped = []
      grouped = {}
      query.available_filters.map do |field, field_options|

        if (( field == "user_id" && ( managers? == false && admin? == false )) || ( field == "author_id" && ( managers? == false && admin? == false )))
          puts("PLUGIN removed")
        else
          if field_options[:type] == :relation
            group = :label_relations
          elsif field_options[:type] == :tree
            group = query.is_a?(IssueQuery) ? :label_relations : nil
          elsif /^cf_\d+\./.match?(field)
            group = (field_options[:through] || field_options[:field]).try(:name)
          elsif field =~ /^(.+)\./
            # association filters
            group = "field_#{$1}".to_sym
          elsif %w(member_of_group assigned_to_role).include?(field)
            group = :field_assigned_to
          elsif field_options[:type] == :date_past || field_options[:type] == :date
            group = :label_date
          elsif %w(estimated_hours spent_time).include?(field)
            group = :label_time_tracking
          end
          if group
            (grouped[group] ||= []) << [field_options[:name], field]
          else
            ungrouped << [field_options[:name], field]
          end
        end

      end
      
      if grouped[:label_date].try(:size) == 1
        ungrouped << grouped.delete(:label_date).first
      end
      s = options_for_select([[]] + ungrouped)
      if grouped.present?
        localized_grouped = grouped.map {|k,v| [k.is_a?(Symbol) ? l(k) : k.to_s, v]}
        s << grouped_options_for_select(localized_grouped)
      end
      s
    end

    def render_query_totals_patch(query)
      if managers? == false && admin? == false
        user_id = User.current.id
        user_filter = {"user_id"=>{:operator=>"=", :values=>[user_id]}}
        merge_filter = query.filters.merge(user_filter)
        query.filters.replace(merge_filter)

        return unless query.totalable_columns.present?
        totals = query.totalable_columns.map do |column|
          total_tag(column, query.total_for(column))
        end
        content_tag('p', totals.join(" ").html_safe, :class => "query-totals")
      else
        return unless query.totalable_columns.present?
        totals = query.totalable_columns.map do |column|
          total_tag(column, query.total_for(column))
        end
        content_tag('p', totals.join(" ").html_safe, :class => "query-totals")
      end
    end
  end
end
QueriesHelper.send(:include, QueriesHelperPatch)
