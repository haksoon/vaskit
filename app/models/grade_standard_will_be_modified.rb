class GradeStandardWillBeModified < ActiveRecord::Base
  has_attached_file :image,
                    url: '/assets/grade_standard_will_be_modifieds/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/grade_standard_will_be_modifieds/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  validates :percent_standard, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100, allow_nil: true }
end
