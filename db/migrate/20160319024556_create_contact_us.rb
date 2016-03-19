class CreateContactUs < ActiveRecord::Migration
  def change
    create_table :contact_us do |t|
      t.integer :user_id
      t.string :message

      t.timestamps null: false
    end
  end
end
