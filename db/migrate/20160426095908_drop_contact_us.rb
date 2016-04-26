class DropContactUs < ActiveRecord::Migration
  def up
    drop_table :contact_us
  end
  
  def down
    create_table :contact_us do |t|
      t.integer :user_id
      t.string :message

      t.timestamps null: false
    end
  end
end
