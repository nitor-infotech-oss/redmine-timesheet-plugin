class CreateCustomItems < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_items do |t|
      t.boolean :month_lock
      t.integer :working_day
    end
  end
end
