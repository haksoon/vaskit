class PreviewImage < ActiveRecord::Base
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  belongs_to :user

  has_attached_file :image,
                    styles: { square: '500x500#', crop: '1024x1024>' },
                    processors: [:cropper],
                    url: '/assets/preview_images/:id/:style/:id.:extension',
                    path: ':rails_root/public/assets/preview_images/:id/:style/:id.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def reprocess_image
    image.reprocess! :square
  end
end
