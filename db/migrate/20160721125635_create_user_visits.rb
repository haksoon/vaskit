class CreateUserVisits < ActiveRecord::Migration
  def change
    create_table :user_visits do |t|
      t.integer :user_id
      t.integer :visitor_id
      t.string :device
      t.string :browser

      t.timestamps null: false
    end
  end
end
