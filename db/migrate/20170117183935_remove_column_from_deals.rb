class RemoveColumnFromDeals < ActiveRecord::Migration
  def change
    remove_column :deals, :deal_category_id
    add_column :share_logs, :collection_id, :integer
  end
end
