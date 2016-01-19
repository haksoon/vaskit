class AddColumnToAskDeal < ActiveRecord::Migration
  def change
    add_column :ask_deals, :content, :string
    add_column :ask_deals, :brand, :string
    add_column :ask_deals, :price, :integer
    add_column :ask_deals, :link, :string
    add_column :ask_deals, :spec1, :string
    add_column :ask_deals, :spec2, :string
    add_column :ask_deals, :spec3, :string
    add_column :asks, :admin_choice, :integer, :default => 0
  end
end
