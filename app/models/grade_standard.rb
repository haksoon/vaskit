class GradeStandard < ActiveRecord::Base
  has_many :user_activity_score

  has_attached_file :image,
                    url: '/assets/grade_standards/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/grade_standards/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']


  def self.daily_update_grade_standard
    GradeStandardWillBeModified.all.each do |grade_standard_will_be_modified|
      if grade_standard_will_be_modified.grade_standard_id
        if grade_standard_will_be_modified.percent_standard
          find_by_id(grade_standard_will_be_modified.grade_standard_id).update(name: grade_standard_will_be_modified.name, percent_standard: grade_standard_will_be_modified.percent_standard , image: grade_standard_will_be_modified.image)
        else
          find_by_id(grade_standard_will_be_modified.grade_standard_id).destroy
        end
      else
        create(name: grade_standard_will_be_modified.name, percent_standard: grade_standard_will_be_modified.percent_standard , image: grade_standard_will_be_modified.image)
      end
      grade_standard_will_be_modified.destroy
    end

    user_count = UserActivityScore.all.count
    order_count = 1
    all.order(percent_standard: :asc).each do |g|
      g.update(grade_order: order_count, score_standard: UserActivityScore.all.order(total_score: :desc).limit(1).offset(user_count*g.percent_standard/100).first.total_score)
      order_count += 1
    end
    UserActivityScore.daily_update_user_grade
  end
end
