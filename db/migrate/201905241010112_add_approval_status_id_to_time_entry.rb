class AddApprovalStatusIdToTimeEntry < ActiveRecord::Migration[5.2]
  def self.up
    add_column :time_entries, :approval_status_id, :integer, :default => 1
  end

  def self.down
    remove_column :time_entries, :approval_status_id
  end
end
