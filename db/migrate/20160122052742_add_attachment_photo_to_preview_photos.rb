class AddAttachmentPhotoToPreviewPhotos < ActiveRecord::Migration
  def self.up
    change_table :preview_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :preview_images, :image
  end
end
