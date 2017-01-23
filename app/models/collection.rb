class Collection < ActiveRecord::Base
  has_attached_file :image,
                    :url  => "/assets/collections/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/collections/:id/:style/:basename.:extension",
                    :default_url => "/images/custom/card_image_preview.png"
  validates_attachment_size :image, :less_than => 20.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  has_many :collection_to_asks
  has_many :collection_to_collection_keywords

  COLLECTION_PER = 3
end
