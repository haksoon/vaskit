class Collection < ActiveRecord::Base
  has_attached_file :image,
                    url: '/assets/collections/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/collections/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  has_many :collection_to_asks
  has_many :collection_to_collection_keywords

  COLLECTION_PER = 3

  before_update :rename_file

  def rename_file
    return if image.blank?
    extension = image_file_name.split('.').last
    return unless %w[jpg jpeg gif png].include?(extension)
    self.image_file_name = "collection.#{extension}"
  end
end
