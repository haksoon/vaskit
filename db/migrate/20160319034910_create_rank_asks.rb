class CreateRankAsks < ActiveRecord::Migration
  def change
    create_table :rank_asks do |t|
      t.integer :ask_id
      t.integer :category_id
      t.integer :ranking

      t.timestamps null: false
    end
  end
end
