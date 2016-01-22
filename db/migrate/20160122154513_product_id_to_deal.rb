class ProductIdToDeal < ActiveRecord::Migration
  def up
    add_column :deals, :product_id, :string
    change_column :deals, :link, :text
  end
  
  def down
    remove_column :deals, :product_id
    change_column :deals, :link, :string
  end
end
