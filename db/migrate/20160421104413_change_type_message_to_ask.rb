class ChangeTypeMessageToAsk < ActiveRecord::Migration
  def up
    change_column :asks, :message, :text
    change_column :asks, :spec1, :text
    change_column :asks, :spec2, :text
    change_column :asks, :spec3, :text
    change_column :ask_deals, :title, :text
    change_column :ask_deals, :brand, :text
    change_column :ask_deals, :link, :text
    change_column :ask_deals, :spec1, :text
    change_column :ask_deals, :spec2, :text
    change_column :ask_deals, :spec3, :text
  end
  
  def down
    change_column :asks, :message, :string
    change_column :asks, :spec1, :string
    change_column :asks, :spec2, :string
    change_column :asks, :spec3, :string
    change_column :ask_deals, :title, :string
    change_column :ask_deals, :brand, :string
    change_column :ask_deals, :link, :string
    change_column :ask_deals, :spec1, :string
    change_column :ask_deals, :spec2, :string
    change_column :ask_deals, :spec3, :string
  end
end
