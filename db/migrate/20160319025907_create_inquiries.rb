class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.integer :user_id
      t.string :message

      t.timestamps null: false
    end
    add_column :users, :is_deleted, :boolean, :default => false
  end
end
