class AddColumnsToUserVisits < ActiveRecord::Migration
  def change
    add_column :user_visits, :referer_host, :string
    add_column :user_visits, :referer_full, :text
    add_column :user_visits, :user_agent, :text
  end
end
