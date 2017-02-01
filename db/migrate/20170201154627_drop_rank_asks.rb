class DropRankAsks < ActiveRecord::Migration
  def up
    drop_table :rank_asks
  end

  def down
    create_table :rank_asks do |t|
      t.integer :ask_id
      t.integer :category_id
      t.integer :ranking

      t.timestamps null: false
    end
  end
end
