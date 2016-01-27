class IsModifyToAskDeal < ActiveRecord::Migration
  def change
    add_column :ask_deals, :is_modify, :boolean, :default => false
  end
end
