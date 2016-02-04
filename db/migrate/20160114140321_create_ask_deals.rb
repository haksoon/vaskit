class CreateAskDeals < ActiveRecord::Migration
  def change
    create_table :ask_deals do |t|
      t.integer :deal_id
      t.integer :user_id
      t.integer :comment_count, :default => 0
      t.integer :vote_count, :default => 0

      t.timestamps null: false
    end
  end
end
