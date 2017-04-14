class CreateUserActivityScores < ActiveRecord::Migration
  def up
    create_table :user_activity_scores do |t|
      t.integer :user_id
      t.integer :cycle_1_score, default: 0
      t.integer :cycle_2_score, default: 0
      t.integer :cycle_3_score, default: 0
      t.integer :cycle_4_score, default: 0
      t.integer :total_score, default: 0
      t.integer :grade_standard_id
    end

    standard_time = Date.today.at_beginning_of_week.to_time + 60*60*6
    standard_time_1 = standard_time - 60 * 60 * 24 * 7
    standard_time_2 = standard_time_1 - 60 * 60 * 24 * 7
    standard_time_3 = standard_time_2 - 60 * 60 * 24 * 7

    Vote.where(is_deleted: false).where('updated_at > ?', standard_time).each do |v|
      if v.user_id
        update_user_score(v.user_id, 1, 1)
      end
    end
    Vote.where(is_deleted: false).where('updated_at > ?', standard_time_1).where('updated_at <= ?', standard_time).each do |v|
      if v.user_id
        update_user_score(v.user_id, 1, 2)
      end
    end
    Vote.where(is_deleted: false).where('updated_at > ?', standard_time_2).where('updated_at <= ?', standard_time_1).each do |v|
      if v.user_id
        update_user_score(v.user_id, 1, 3)
      end
    end
    Vote.where(is_deleted: false).where('updated_at > ?', standard_time_3).where('updated_at <= ?', standard_time_2).each do |v|
      if v.user_id
        update_user_score(v.user_id, 1, 4)
      end
    end


    Comment.where(is_deleted: false).where('updated_at > ?', standard_time).each do |c|
      if c.user_id != Ask.find_by_id(c.ask_id).user_id
        if c.content.length < 50
          update_user_score(c.user_id, 10, 1)
        elsif c.content.length < 100
          update_user_score(c.user_id, 15, 1)
        else
          update_user_score(c.user_id, 20, 1)
        end
      end
      if c.comment_id
        original_comment_user_id = Comment.find_by_id(c.comment_id).user_id
        if original_comment_user_id != c.user_id && original_comment_user_id != Ask.find_by_id(c.ask_id).user_id
          update_user_score(original_comment_user_id, 3, 1)
        end
      end
    end

    Comment.where(is_deleted: false).where('updated_at > ?', standard_time_1).where('updated_at <= ?', standard_time).each do |c|
      if c.user_id != Ask.find_by_id(c.ask_id).user_id
        if c.content.length < 50
          update_user_score(c.user_id, 10, 2)
        elsif c.content.length < 100
          update_user_score(c.user_id, 15, 2)
        else
          update_user_score(c.user_id, 20, 2)
        end
      end
      if c.comment_id
        original_comment_user_id = Comment.find_by_id(c.comment_id).user_id
        if original_comment_user_id != c.user_id && original_comment_user_id != Ask.find_by_id(c.ask_id).user_id
          update_user_score(original_comment_user_id, 3, 2)
        end
      end
    end

    Comment.where(is_deleted: false).where('updated_at > ?', standard_time_2).where('updated_at <= ?', standard_time_1).each do |c|
      if c.user_id != Ask.find_by_id(c.ask_id).user_id
        if c.content.length < 50
          update_user_score(c.user_id, 10, 3)
        elsif c.content.length < 100
          update_user_score(c.user_id, 15, 3)
        else
          update_user_score(c.user_id, 20, 3)
        end
      end
      if c.comment_id
        original_comment_user_id = Comment.find_by_id(c.comment_id).user_id
        if original_comment_user_id != c.user_id && original_comment_user_id != Ask.find_by_id(c.ask_id).user_id
          update_user_score(original_comment_user_id, 3, 3)
        end
      end
    end

    Comment.where(is_deleted: false).where('updated_at > ?', standard_time_3).where('updated_at <= ?', standard_time_2).each do |c|
      if c.user_id != Ask.find_by_id(c.ask_id).user_id
        if c.content.length < 50
          update_user_score(c.user_id, 10, 4)
        elsif c.content.length < 100
          update_user_score(c.user_id, 15, 4)
        else
          update_user_score(c.user_id, 20, 4)
        end
      end
      if c.comment_id
        original_comment_user_id = Comment.find_by_id(c.comment_id).user_id
        if original_comment_user_id != c.user_id && original_comment_user_id != Ask.find_by_id(c.ask_id).user_id
          update_user_score(original_comment_user_id, 3, 4)
        end
      end
    end


    CommentLike.where(is_deleted: false).where('updated_at > ?', standard_time).each do |c|
      update_user_score(c.user_id, 1, 1)
      update_user_score(Comment.find_by_id(c.comment_id).user_id, 3, 1)
    end

    CommentLike.where(is_deleted: false).where('updated_at > ?', standard_time_1).where('updated_at <= ?', standard_time).each do |c|
      update_user_score(c.user_id, 1, 2)
      update_user_score(Comment.find_by_id(c.comment_id).user_id, 3, 2)
    end

    CommentLike.where(is_deleted: false).where('updated_at > ?', standard_time_2).where('updated_at <= ?', standard_time_1).each do |c|
      update_user_score(c.user_id, 1, 3)
      update_user_score(Comment.find_by_id(c.comment_id).user_id, 3, 3)
    end

    CommentLike.where(is_deleted: false).where('updated_at > ?', standard_time_3).where('updated_at <= ?', standard_time_2).each do |c|
      update_user_score(c.user_id, 1, 4)
      update_user_score(Comment.find_by_id(c.comment_id).user_id, 3, 4)
    end

    UserActivityScore.all.each do |u|
      u.update(total_score: u.cycle_1_score + u.cycle_2_score + u.cycle_3_score + u.cycle_4_score)
    end
  end

  def down
    drop_table :user_activity_scores
  end

  def update_user_score(user_id, score, week)
    user_activity_score = UserActivityScore.find_by(user_id: user_id)
    if user_activity_score == nil
      user_activity_score = UserActivityScore.create(user_id: user_id)
    end
    if week == 1
      user_activity_score.update(cycle_1_score: user_activity_score.cycle_1_score + score)
    elsif week == 2
      user_activity_score.update(cycle_2_score: user_activity_score.cycle_2_score + score)
    elsif week == 3
      user_activity_score.update(cycle_3_score: user_activity_score.cycle_3_score + score)
    elsif week == 4
      user_activity_score.update(cycle_4_score: user_activity_score.cycle_4_score + score)
    end
  end

end
