class AddColumnToAskDeal < ActiveRecord::Migration
  def change
    add_column :ask_deals, :title, :string
    add_column :ask_deals, :brand, :string
    add_column :ask_deals, :price, :string
    add_column :ask_deals, :link, :string
    add_column :ask_deals, :spec1, :string
    add_column :ask_deals, :spec2, :string
    add_column :ask_deals, :spec3, :string
    add_column :asks, :admin_choice, :integer, :default => 0
  end
end
