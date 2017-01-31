class AddAttachmentImageToVideos < ActiveRecord::Migration
  def up
    add_attachment :videos, :image
  end

  def down
    remove_attachment :videos, :image
  end
end
