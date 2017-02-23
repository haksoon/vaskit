class AddColumnToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :show, :boolean, default: false
    add_column :videos, :description, :text
    add_column :share_logs, :video_id, :integer
  end
end
