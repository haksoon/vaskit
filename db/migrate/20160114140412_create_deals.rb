class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.string :title
      t.string :brand
      t.integer :price
      t.string :link
      t.string :spec1
      t.string :spec2
      t.string :spec3

      t.timestamps null: false
    end
  end
end
