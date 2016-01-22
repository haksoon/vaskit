class AddAttachmentImageToAskDeals < ActiveRecord::Migration
  def self.up
    change_table :ask_deals do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :ask_deals, :image
  end
end
