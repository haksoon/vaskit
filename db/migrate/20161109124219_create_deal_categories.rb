class CreateDealCategories < ActiveRecord::Migration
  def change
    create_table :deal_categories do |t|
      t.integer :category_id
      t.string :category_1
      t.string :category_2
      t.string :category_3
      t.string :category_4

      t.timestamps null: false
    end

    add_column :deals, :deal_category_id, :integer
  end
end
