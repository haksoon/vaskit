class CreateAlrams < ActiveRecord::Migration
  def change
    create_table :alrams do |t|
      t.integer :user_id
      t.integer :send_user_id
      t.integer :ask_owner_user_id
      t.integer :ask_id
      t.string :alram_type
      t.boolean :is_read, :default => false

      t.timestamps null: false
    end
  end
end
