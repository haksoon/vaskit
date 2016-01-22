class PreviewImage < ActiveRecord::Base
  
  has_attached_file :image, :styles => { :normal => "180x180#" },
                    :url  => "/assets/preview_images/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/preview_images/:id/:style/:basename.:extension",
                    :default_url => "/images/common/profile_photo.png"
  validates_attachment_size :image, :less_than => 20.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']
  
end
