class GradeStandard < ActiveRecord::Base
  default_scope { order(grade_order: :asc) }
  has_many :user_activity_score
  has_one :grade_standard_will_be_modified

  has_attached_file :image,
                    url: '/assets/grade_standards/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/grade_standards/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  def self.update_by_daily
    user_count = UserActivityScore.all.count
    return if user_count.zero?
    all.unscoped.order(percent_standard: :asc).each_with_index do |g, index|
      score_offset = user_count * g.percent_standard / 100 - 1
      score_standard = UserActivityScore.all.order(total_score: :desc)
                                        .limit(1).offset(score_offset)
                                        .first.total_score
      g.update(grade_order: index + 1, score_standard: score_standard)
    end
  end
end
