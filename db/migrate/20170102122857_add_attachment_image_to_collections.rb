class AddAttachmentImageToCollections < ActiveRecord::Migration
  def self.up
    change_table :collections do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :collections, :image
  end
end
