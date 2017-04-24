class GradeStandardWillBeModified < ActiveRecord::Base
  belongs_to :grade_standard

  has_attached_file :image,
                    url: '/assets/grade_standard_will_be_modifieds/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/grade_standard_will_be_modifieds/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  validates :percent_standard, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100, allow_nil: true }

  def self.update_by_daily
    all.each do |m|
      if m.grade_standard.nil?
        GradeStandard.create(name: m.name,
                             percent_standard: m.percent_standard,
                             image: m.image)
      elsif m.percent_standard
        m.grade_standard.update(name: m.name,
                                percent_standard: m.percent_standard,
                                image: m.image)
      else
        m.grade_standard.destroy
      end
      m.destroy
    end
  end
end
