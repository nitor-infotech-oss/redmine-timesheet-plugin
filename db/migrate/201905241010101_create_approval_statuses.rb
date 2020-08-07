class CreateApprovalStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :approval_statuses do |t|
      t.column "status", :string, :default => "Pending"
    end
  end
end
