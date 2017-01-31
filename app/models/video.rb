class Video < ActiveRecord::Base
  has_attached_file :image,
                    :url  => "/assets/videos/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/videos/:id/:style/:basename.:extension",
                    :default_url => "/images/custom/card_image_preview.png"
  validates_attachment_size :image, :less_than => 20.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  belongs_to :ask

  VIDEO_PER = 3

  before_create :rename_file
  before_update :rename_file

  def rename_file
    if self.image_file_name != nil
      if ["jpg", "jpeg", "gif", "png"].include? (self.image_file_name.split(".").last)
        self.image_file_name = "video." +  self.image_file_name.split(".").last
      end
    end
  end
end
