class UserActivityScore < ActiveRecord::Base
  belongs_to :user
  belongs_to :grade_standard

  def self.update_by(action, related_action = nil)
    target_user_id = related_action ? related_action.user_id : action.user_id
    return if target_user_id.nil?

    target_user = find_by(user_id: target_user_id)
    target_user = create(user_id: target_user_id) if target_user.nil?

    score =
      if related_action.nil?
        case action.class.name
        when 'Vote'                             then 1
        when 'CommentLike'                      then 1
        when 'Comment'
          if action.content.length < 50         then 10
          elsif action.content.length < 100     then 15
          else                                       20
          end
        end
      else
        case action.class.name
        when 'CommentLike'                      then 3
        when 'Comment'                          then 3
        end
      end
    score *= -1 if action.is_deleted

    new_score = target_user.cycle_1_score + score
    if new_score > 0
      target_user.total_score += score
      target_user.cycle_1_score = new_score
    else
      target_user.total_score -= target_user.cycle_1_score
      target_user.cycle_1_score = 0
    end
    user_score = target_user.total_score

    current_grade = target_user.grade_standard
    if current_grade.nil? || score > 0 && current_grade.grade_order > 1
      next_grade = GradeStandard.where('score_standard <= ?', user_score).first
      target_user.grade_standard_id = next_grade.id unless next_grade.nil?
      is_upgraded = true unless next_grade.nil?
    elsif score < 0 && user_score < current_grade.score_standard
      prev_grade = GradeStandard.where('score_standard < ?', user_score).first
      target_user.grade_standard_id = prev_grade.nil? ? nil : prev_grade.id
    end

    is_upgraded if target_user.save
  end

  def self.update_by_weekly
    return unless Date.today.wday == 1
    all.each do |u|
      updated_total_score = u.cycle_1_score + u.cycle_2_score + u.cycle_3_score
      if updated_total_score.zero?
        u.destroy
      else
        u.update(cycle_1_score: 0,
                 cycle_2_score: u.cycle_1_score,
                 cycle_3_score: u.cycle_2_score,
                 cycle_4_score: u.cycle_3_score,
                 total_score: updated_total_score)
      end
    end
  end

  def self.update_by_daily
    grade_standards = GradeStandard.all.unscoped
    return if grade_standards.count.zero?
    grade_standards = grade_standards.order(grade_order: :desc)
    all.unscoped.each do |u|
      u.grade_standard_id = nil
      grade_standards.each do |g|
        next if u.total_score < g.score_standard
        u.grade_standard_id = g.id
      end
      u.save if u.changed?
    end
  end

  def self.daily_update
    UserActivityScore.update_by_weekly
    GradeStandardWillBeModified.update_by_daily
    GradeStandard.update_by_daily
    UserActivityScore.update_by_daily
  end
end
