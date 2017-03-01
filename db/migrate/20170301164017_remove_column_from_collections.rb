class RemoveColumnFromCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :related_collections, :string
    rename_column :videos, :url, :fb_id
    add_column :videos, :yt_id, :string
  end
end
