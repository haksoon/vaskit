class Comment < ActiveRecord::Base
  belongs_to :user
  has_many :comment_likes

  has_attached_file :image,
                    styles: { normal: '300>x' },
                    url: '/assets/comments/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/comments/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  after_create :reload_ask_deal_comment_count, :create_comment_alarm
  after_update :reload_ask_deal_comment_count
  after_destroy :reload_ask_deal_comment_count

  validates :ask_id, presence: true
  validates :ask_deal_id, presence: true
  validates :content, presence: true
  validates :user_id, presence: true

  def generate_hash_tags
    HashTag.destroy_all(ask_id: ask_id, comment_id: id)
    # 업데이트의 경우 기존 해시태그를 모두 삭제한 후 재설정
    return if is_deleted
    hash_tags = content.scan(/#[0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]+/)
    hash_tags.each do |hash_tag|
      hash_tag = hash_tag.tr('#', '').tr(',', '')
      HashTag.create(ask_id: ask_id, comment_id: id, user_id: user_id, keyword: hash_tag)
    end
  end

  def reload_ask_deal_comment_count
    ask = Ask.find(ask_id)
    ask_deal = ask_deal_id == ask.left_ask_deal_id ? ask.left_ask_deal : ask.right_ask_deal
    comment_count = Comment.where(ask_deal_id: ask_deal_id,
                                  is_deleted: false).count
    ask_deal.update(comment_count: comment_count)
  end

  def create_comment_alarm
    ask = Ask.find(ask_id)

    # 본인의 질문에 대한 댓글 알림 (type:comment)
    if !ask.be_completed && user_id != ask.user_id && User.find(ask.user_id).alarm_3 == true
      comment_count = Comment.where(ask_id: ask.id, is_deleted: false)
                             .where.not(user_id: ask.user_id).count
      alarm = Alarm.where(user_id: ask.user_id,
                          ask_id: ask.id)
                   .where('alarm_type LIKE ?', 'comment_%').first
      if alarm
        alarm.update(is_read: false,
                     send_user_id: user_id,
                     alarm_type: "comment_#{comment_count}")
      else
        Alarm.create(user_id: ask.user_id,
                     send_user_id: user_id,
                     ask_id: ask.id,
                     alarm_type: "comment_#{comment_count}")
      end
    end

    if comment_id.nil?
      # 본인이 댓글 단 질문에 추가 댓글 알림 (type:sub_comment)
      # 과거에 달았던 애가 있는지 체크
      sub_comments = Comment.where(ask_id: ask.id, is_deleted: false)
                            .where("id < #{id}").uniq
      sub_comments.each_with_index do |sub_comment|
        next unless sub_comment.user_id != ask.user_id && sub_comment.user_id != user_id
        next unless User.find(sub_comment.user_id).alarm_6 == true
        sub_comment = Comment.where(ask_id: ask.id,
                                    is_deleted: false,
                                    user_id: sub_comment.user_id).first
        user_count = Comment.where(ask_id: ask.id, is_deleted: false)
                            .where("id > #{sub_comment.id}")
                            .where.not(user_id: sub_comment.user_id).count
        alarm = Alarm.where(user_id: sub_comment.user_id,
                            ask_owner_user_id: ask.user_id,
                            ask_id: ask.id)
                     .where('alarm_type LIKE ?', 'sub_comment_%').first
        if alarm
          alarm.update(is_read: false,
                       send_user_id: user_id,
                       alarm_type: "sub_comment_#{user_count}")
        else
          Alarm.create(user_id: sub_comment.user_id,
                       send_user_id: user_id,
                       ask_owner_user_id: ask.user_id,
                       ask_id: ask.id,
                       alarm_type: "sub_comment_#{user_count}")
        end
      end

    # 대댓글 작성시 알람 생성
    else
      original_comment = Comment.find(comment_id)

      # 본인의 댓글에 대한 대댓글 알림 (type:reply_comment)
      if original_comment.user_id != user_id && User.find(original_comment.user_id).alarm_5 == true
        comment_count = Comment.where(comment_id: comment_id,
                                      is_deleted: false).count
        alarm = Alarm.where(user_id: original_comment.user_id,
                            ask_id: ask.id)
                     .where('alarm_type LIKE ?', 'reply_comment_%').first
        if alarm
          alarm.update(is_read: false,
                       send_user_id: user_id,
                       alarm_type: "reply_comment_#{comment_count}")
        else
          Alarm.create(user_id: original_comment.user_id,
                       send_user_id: user_id,
                       ask_id: ask.id,
                       alarm_type: "reply_comment_#{comment_count}")
        end
      end

      # 본인이 대댓글 단 댓글에 대한 추가 대댓글 알림 (type:reply_sub_comment)
      reply_sub_comments = Comment.where(ask_id: ask.id,
                                         comment_id: original_comment.id,
                                         is_deleted: false)
                                  .where("id < #{id}").uniq
      reply_sub_comments.each_with_index do |reply_sub_comment|
        next unless user_id != reply_sub_comment.user_id
        next unless User.find(reply_sub_comment.user_id).alarm_6 == true
        reply_sub_comment = Comment.where(comment_id: original_comment.id,
                                          is_deleted: false,
                                          user_id: reply_sub_comment.user_id).first
        user_count = Comment.where(comment_id: original_comment.id,
                                   is_deleted: false)
                            .where("id > #{reply_sub_comment.id}")
                            .where.not(user_id: reply_sub_comment.user_id).count
        alarm = Alarm.where(user_id: reply_sub_comment.user_id,
                            ask_id: ask.id,
                            comment_owner_user_id: original_comment.user_id,
                            comment_id: original_comment.id)
                     .where('alarm_type LIKE ?', 'reply_sub_comment_%').first
        if alarm
          alarm.update(is_read: false,
                       send_user_id: user_id,
                       alarm_type: "reply_sub_comment_#{user_count}")
        else
          Alarm.create(user_id: reply_sub_comment.user_id,
                       send_user_id: user_id,
                       ask_id: ask.id,
                       comment_owner_user_id: original_comment.user_id,
                       comment_id: original_comment.id,
                       alarm_type: "reply_sub_comment_#{user_count}")
        end
      end

    end
  end
  handle_asynchronously :create_comment_alarm
end
