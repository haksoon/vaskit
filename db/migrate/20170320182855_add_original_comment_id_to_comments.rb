class AddOriginalCommentIdToComments < ActiveRecord::Migration
  def up
    add_column :alarms, :original_comment_id, :integer

    AskLike.all.each do |ask_like|
      if ask_like.ask.nil?
        ask_like.delete
      elsif ask_like.ask.user_id == ask_like.user_id
        ask_like.destroy
      end
    end

    # 질문자에 대한 공감 알림 수정 (299/299)
    like_ask_alarms = Alarm.where('alarm_type LIKE ?', 'like_ask_%')
    like_ask_alarms.each do |alarm|
      ask_likes = AskLike.where(ask_id: alarm.ask_id)
      if ask_likes.size > 0
        last_like = ask_likes.last
        alarm_type = "like_ask_#{ask_likes.count}"
        alarm.update_columns(alarm_type: alarm_type, send_user_id: last_like.user_id)
      else
        # 신규 공감 레코드가 모두 삭제된 경우
        alarm.update_columns(alarm_type: 'like_ask_not_exists', user_id: nil)
      end
    end

    # 질문자에 대한 댓글 알림 수정 (1_656/1_656)
    comment_alarms = Alarm.where('alarm_type LIKE ?', 'comment_%')
    comment_alarms.each do |alarm|
      ask_comments = Comment.where(ask_id: alarm.ask_id, is_deleted: false).where.not(user_id: alarm.user_id)
      ask_comments = ask_comments.where('created_at < ?', alarm.ask.ask_complete.created_at) if alarm.ask.be_completed
      if ask_comments.size > 0
        last_comment = ask_comments.last
        alarm_type = "comment_#{ask_comments.count}"
        alarm.update_columns(alarm_type: alarm_type, send_user_id: last_comment.user_id, comment_id: last_comment.id)
      else
        # 신규 코멘트 레코드가 모두 삭제된 경우 3 rows
        alarm.update_columns(alarm_type: 'comment_not_exists', user_id: nil)
      end
    end

    CommentLike.all.each do |comment_like|
      if comment_like.comment.nil?
        comment_like.delete
      elsif comment_like.comment.user_id == comment_like.user_id
        comment_like.destroy
      end
    end

    # 댓글 좋아요 알림 수정 (833/2_434)
    like_comment_alarms = Alarm.where('alarm_type LIKE ?', 'like_comment_%')
    like_comment_alarms.each do |alarm|
      if alarm.comment_id.nil?
        comment_ids = Comment.where(ask_id: alarm.ask_id, user_id: alarm.user_id, is_deleted: false).pluck(:id)
      else
        comment_ids = Comment.where(id: alarm.comment_id, ask_id: alarm.ask_id, user_id: alarm.user_id, is_deleted: false).pluck(:id)
      end

      if comment_ids.size.zero?
        # 내 댓글 레코드가 삭제된 경우 6 rows
        alarm.update_columns(alarm_type: 'like_comment_comment_not_exists', user_id: nil, comment_id: nil)
      elsif comment_ids.size == 1
        comment_id = comment_ids[0]
        comment_likes = CommentLike.where(comment_id: comment_id)
        if comment_likes.size > 0
          last_like = comment_likes.last
          alarm_type = "like_comment_#{comment_likes.count}"
          alarm.update_columns(alarm_type: alarm_type, send_user_id: last_like.user_id, comment_id: nil, original_comment_id: comment_id)
        else
          # 댓글 좋아요 레코드가 모두 삭제된 경우 21 rows
          alarm.update_columns(alarm_type: 'like_comment_like_not_exists', user_id: nil, comment_id: nil)
        end
      else
        # 댓글이 여러개인 경우 가장 많은 좋아요를 받은 댓글을 기준으로 선택
        comment_likes = CommentLike.where(comment_id: comment_ids)
        if comment_likes.size > 0
          comment_id = comment_likes.group(:comment_id).select('*, COUNT(*) AS count').order('count DESC').first.comment_id
          comment_like = CommentLike.where(comment_id: comment_id)
          last_like = comment_like.last
          alarm_type = "like_comment_#{comment_like.count}"
          alarm.update_columns(alarm_type: alarm_type, send_user_id: last_like.user_id, comment_id: nil, original_comment_id: comment_id)
        else
          # 댓글 좋아요 레코드가 모두 삭제된 경우 1 rows
          alarm.update_columns(alarm_type: 'like_comment_like_not_exists', user_id: nil, comment_id: nil)
        end
      end
    end


    # 대댓글 알림 수정 (1_537/1_537)
    reply_comment_alarms = Alarm.where('alarm_type LIKE ?', 'reply_comment_%')
    reply_comment_alarms.each do |alarm|
      comment_ids = Comment.where(ask_id: alarm.ask_id, user_id: alarm.user_id, is_deleted: false, comment_id: nil).pluck(:id)
      if comment_ids.size.zero?
        # 원댓글 레코드가 삭제된 경우 3 rows
        alarm.update_columns(alarm_type: 'reply_comment_origin_not_exists', user_id: nil)
      elsif comment_ids.size == 1
        comment_id = comment_ids[0]
        reply_comments = Comment.where(ask_id: alarm.ask_id, is_deleted: false, comment_id: comment_id).where.not(user_id: alarm.user_id)
        if reply_comments.size > 0
          last_comment = reply_comments.last
          alarm_type = "reply_comment_#{reply_comments.count}"
          alarm.update_columns(alarm_type: alarm_type, send_user_id: last_comment.user_id, comment_id: last_comment.id, original_comment_id: comment_id)
        else
          # 대댓글이 모두 삭제된 경우 3 rows
          alarm.update_columns(alarm_type: 'reply_comment_reply_not_exists', user_id: nil)
        end
      else
        # 원댓글이 여러개인 경우 가장 많은 대댓글이 작성된 댓글을 기준으로 선택
        reply_comments = Comment.where(ask_id: alarm.ask_id, is_deleted: false, comment_id: comment_ids).where.not(user_id: alarm.user_id)
        if reply_comments.size > 0
          comment_id = reply_comments.group(:comment_id).select('*, COUNT(*) AS count').order('count DESC').first.comment_id
          reply_comment = Comment.where(ask_id: alarm.ask_id, is_deleted: false, comment_id: comment_id).where.not(user_id: alarm.user_id)
          last_reply = reply_comment.last
          alarm_type = "reply_comment_#{reply_comment.count}"
          alarm.update_columns(alarm_type: alarm_type, send_user_id: last_reply.user_id, comment_id: last_reply.id, original_comment_id: comment_id)
        else
          # 대댓글이 모두 삭제된 경우
          alarm.update_columns(alarm_type: 'reply_comment_reply_not_exists', user_id: nil, comment_id: nil)
        end
      end
    end

    # 추가 댓글 알림 수정 (7_306/7_306)
    sub_comment_alarms = Alarm.where('alarm_type LIKE ?', 'sub_comment_%')
    sub_comment_alarms.each do |alarm|
      my_comment = Comment.where(ask_id: alarm.ask_id, user_id: alarm.user_id, is_deleted: false).first
      if my_comment.nil?
        # 내 코멘트 레코드를 삭제한 경우 12 rows
        alarm.update_columns(alarm_type: 'sub_comment_my_not_exitsts', user_id: nil)
      else
        sub_comments = Comment.where(ask_id: alarm.ask_id, is_deleted: false).where.not(user_id: alarm.user_id).where('created_at > ?', my_comment.created_at)
        if sub_comments.size > 0
          last_comment = sub_comments.last
          alarm_type = "sub_comment_#{sub_comments.count}"
          alarm.update_columns(alarm_type: alarm_type, send_user_id: last_comment.user_id, comment_id: last_comment.id)
        else
          # 추가 코멘트 레코드를 모두 삭제한 경우 4 rows
          alarm.update_columns(alarm_type: 'sub_comment_sub_not_exists', user_id: nil)
        end
      end
    end

    # 추가 대댓글 알림 수정 (84/84)
    reply_sub_comment_alarms = Alarm.where('alarm_type LIKE ?', 'reply_sub_comment_%')
    reply_sub_comment_alarms.each do |alarm|
      alarm.update_columns(original_comment_id: alarm.comment_id)
      my_comment = Comment.where(comment_id: alarm.comment_id, is_deleted: false, user_id: alarm.user_id).first
      if my_comment.nil?
        # 내 기존 대댓글 레코드를 삭제한 경우 0 rows
        alarm.update_columns(alarm_type: 'reply_sub_comment_my_not_exists', user_id: nil)
      else
        reply_comments = Comment.where(comment_id: alarm.comment_id, is_deleted: false).where.not(user_id: alarm.user_id).where('created_at > ?', my_comment.created_at)
        if reply_comments.size > 0
          last_comment = reply_comments.last
          alarm_type = "reply_sub_comment_#{reply_comments.count}"
          alarm.update_columns(alarm_type: alarm_type, send_user_id: last_comment.user_id, comment_id: last_comment.id)
        else
          # 추가 대댓글 레코드를 모두 삭제한 경우 0 rows
          alarm.update_columns(alarm_type: 'reply_sub_comment_sub_not_exists', user_id: nil)
        end
      end
    end
  end

  def down
    remove_column :alarms, :original_comment_id
  end
end
