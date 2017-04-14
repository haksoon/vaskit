class GradeStandard < ActiveRecord::Base
  has_many :user_activity_score

  has_attached_file :image,
                    url: '/assets/grade_standards/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/grade_standards/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  def self.daily_update_grade_standard
    GradeStandardWillBeModified.all.each do |m|
      if m.grade_standard_id
        if m.percent_standard
          find_by_id(m.grade_standard_id).update(name: m.name, percent_standard: m.percent_standard , image: m.image)
        else
          find_by_id(m.grade_standard_id).destroy
        end
      else
        create(name: m.name, percent_standard: m.percent_standard , image: m.image)
      end
      m.destroy
    end

    user_count = UserActivityScore.all.count
    order_count = 1
    if UserActivityScore.all.count > 0
      all.order(percent_standard: :asc).each do |g|
        g.update(grade_order: order_count, score_standard: UserActivityScore.all.order(total_score: :desc).limit(1).offset(user_count*g.percent_standard/100).first.total_score)
        order_count += 1
      end
    end
    UserActivityScore.daily_update_user_grade
  end
end
