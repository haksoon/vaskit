class UserActivityScore < ActiveRecord::Base
  belongs_to :user
  belongs_to :grade_standard

  def self.update_user_grade(user_id, action)
    score = 0
    did_upgrade = false

    case action
    when "vote" #투표
      score = 1
    when "vote_deleted" #투표삭제
      score = -1
    when "comment" #댓글, 대댓글달기(50자 미만)
      score = 10
    when "comment_50" #댓글, 대댓글달기(100자 미만)
      score = 15
    when "comment_100" #댓글, 대댓글달기(100자 이상)
      score = 20
    when "comment_deleted" #댓글, 대댓글삭제(50자 미만)
      score = -10
    when "comment_50_deleted" #댓글, 대댓글삭제(100자 미만)
      score = -15
    when "comment_100_deleted" #댓글, 대댓글삭제(100자 이상)
      score = -20
    when "original_comment" #대댓글이 달렸을떄
      score = 3
    when "comment_like" #댓글 좋아요
      score = 1
    when "original_comment_like" #댓글이 좋아요를 받았을때
      score = 3
    when "comment_like_deleted" #댓글 좋아요 취소
      score = -1
    when "original_comment_like_deleted" #댓글의 좋아요가 취소됐을때
      score = -3
    end

    user_activity_score = find_by(user_id: user_id)
    if user_activity_score == nil
      user_activity_score = create(user_id: user_id)
    end
    if user_activity_score.cycle_1_score + score > 0
      user_activity_score.update(cycle_1_score: user_activity_score.cycle_1_score + score, total_score: user_activity_score.total_score + score)
    else
      user_activity_score.update(cycle_1_score: 0, total_score: user_activity_score.cycle_2_score + user_activity_score.cycle_3_score + user_activity_score.cycle_4_score)
    end

    grade_standard_id = user_activity_score.grade_standard_id
    total_score = user_activity_score.total_score

    if grade_standard_id
      current_grade_standard = GradeStandard.find_by_id(grade_standard_id)
      if score > 0
        if current_grade_standard.grade_order > 1
          next_grade = GradeStandard.find_by(grade_order: current_grade_standard.grade_order - 1)
          if total_score >= next_grade.score_standard
            grade_standard_id = next_grade.id
            did_upgrade = true
          end
        end
      elsif score < 0
        if total_score < current_grade_standard.score_standard
          if current_grade_standard.grade_order < GradeStandard.all.count
            grade_standard_id = GradeStandard.find_by(grade_order: current_grade_standard.grade_order + 1).id
          else
            grade_standard_id = nil
          end
        end
      end
    else
      next_grade = GradeStandard.find_by(grade_order: GradeStandard.all.count)
      if next_grade != nil && total_score >= next_grade.score_standard
        grade_standard_id = next_grade.id
      end
    end

    user_activity_score.update(grade_standard_id: grade_standard_id)

    return did_upgrade
  end

  def self.weekly_update_user_grade
    if Date.today.wday == 1
      all.each do |u|
        if u.cycle_1_score + u.cycle_2_score + u.cycle_3_score == 0
          u.destroy
        else
          u.update(cycle_1_score: 0, cycle_2_score: u.cycle_1_score, cycle_3_score: u.cycle_2_score, cycle_4_score: u.cycle_3_score, total_score: u.cycle_1_score + u.cycle_2_score + u.cycle_3_score)
        end
      end
    end
    GradeStandard.daily_update_grade_standard
  end

  def self.daily_update_user_grade
    grade_standard_count = GradeStandard.all.count
    all.each do |u|
      user_grade_standard_id = nil
      for i in 0..grade_standard_count-1
        next_grade_standard = GradeStandard.find_by(grade_order: grade_standard_count-i)
        break if u.total_score < next_grade_standard.score_standard
        user_grade_standard_id = next_grade_standard.id
      end
      u.update(grade_standard_id: user_grade_standard_id)
    end
  end
end
