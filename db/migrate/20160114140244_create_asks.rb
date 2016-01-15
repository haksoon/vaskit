class CreateAsks < ActiveRecord::Migration
  def change
    create_table :asks do |t|
      t.integer :user_id
      t.integer :category_id
      t.integer :left_ask_deal_id
      t.integer :right_ask_deal_id
      t.string :message
      t.boolean :be_completed

      t.timestamps null: false
    end
  end
end
