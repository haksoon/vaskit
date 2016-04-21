class ChangeTypeMessageToAsk < ActiveRecord::Migration
  def up
    change_column :asks, :message, :text
    change_column :asks, :spec1, :text
    change_column :asks, :spec2, :text
    change_column :asks, :spec3, :text
    change_column :ask_deals, :title, :text
    change_column :ask_deals, :brand, :text
    change_column :ask_deals, :link, :text
    change_column :ask_deals, :sepc1, :text
    change_column :ask_deals, :sepc2, :text
    change_column :ask_deals, :sepc3, :text
  end
  
  def down
    change_column :asks, :message, :string
    change_column :asks, :spec1, :string
    change_column :asks, :spec2, :string
    change_column :asks, :spec3, :string
    change_column :ask_deals, :title, :string
    change_column :ask_deals, :brand, :string
    change_column :ask_deals, :link, :string
    change_column :ask_deals, :sepc1, :string
    change_column :ask_deals, :sepc2, :string
    change_column :ask_deals, :sepc3, :string
  end
end
