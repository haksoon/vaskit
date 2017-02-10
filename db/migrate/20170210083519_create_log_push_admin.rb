class CreateLogPushAdmin < ActiveRecord::Migration
  def change
    create_table :log_push_admins do |t|
      t.string :push_type
      t.integer :total_count
      t.integer :ios_count
      t.integer :aos_count
      t.integer :success_count
      t.integer :failure_count
      t.string :message
      t.timestamps null: false
    end
  end
end
