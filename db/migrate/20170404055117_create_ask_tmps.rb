class CreateAskTmps < ActiveRecord::Migration
  def change
    create_table :ask_tmps do |t|
      t.integer  :user_id
      t.integer  :left_ask_deal_id
      t.integer  :right_ask_deal_id
      t.text     :message
      t.text     :spec1
      t.text     :spec2
      t.text     :spec3
      t.timestamps null: false
    end

    create_table :ask_deal_tmps do |t|
      t.text :title
      t.text :brand
      t.integer :price
      t.text :link
      t.text :spec1
      t.text :spec2
      t.text :spec3
      t.integer :preview_image_id
      t.timestamps null: false
    end
  end
end
