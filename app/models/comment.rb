class Comment < ActiveRecord::Base
  scope :is_show_only, -> { where(is_deleted: false) }

  belongs_to :user
  belongs_to :ask
  belongs_to :ask_deal
  belongs_to :original_comment, class_name: 'Comment', foreign_key: 'comment_id'
  has_many :comment_likes
  has_many :hash_tags
  has_many :alarms
  has_many :reply_comments, -> { is_show_only }, class_name: 'Comment', foreign_key: 'comment_id'

  has_attached_file :image,
                    styles: { normal: '300>x' },
                    url: '/assets/comments/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/comments/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  validates :ask_id, presence: true
  validates :ask_deal_id, presence: true
  validates :content, presence: true
  validates :user_id, presence: true

  after_create :reload_ask_deal_comment_count, :create_comment_alarm, :create_reply_comment_alarm, :create_sub_comment_alarm, :create_reply_sub_comment_alarm, :create_liked_ask_comment_alarm
  after_update :reload_ask_deal_comment_count, :create_comment_alarm, :create_reply_comment_alarm, :create_sub_comment_alarm, :create_reply_sub_comment_alarm, :create_liked_ask_comment_alarm, if: :is_deleted

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
    ask = self.ask
    left_comment_count = Comment.where(ask_deal_id: ask.left_ask_deal_id, is_deleted: false).count
    right_comment_count = Comment.where(ask_deal_id: ask.right_ask_deal_id, is_deleted: false).count
    ask.left_ask_deal.update_columns(comment_count: left_comment_count)
    ask.right_ask_deal.update_columns(comment_count: right_comment_count)
  end

  # 본인의 질문에 대한 댓글 알림 (alarm_3, type: comment)
  def create_comment_alarm
    ask = self.ask

    return if ask.be_completed || user_id == ask.user_id
    return unless ask.user.alarm_3

    comments = Comment.where(ask_id: ask.id,
                             is_deleted: false)
                      .where.not(user_id: ask.user_id)
    comment_count = comments.count

    alarm = Alarm.where(user_id: ask.user_id,
                        ask_id: ask.id)
                 .where('alarm_type LIKE ?', 'comment_%').first

    if alarm
      alarm_count = alarm.alarm_type.delete('comment_').to_i
      if comment_count.zero?
        alarm.update_columns(user_id: nil,
                             alarm_type: "comment_#{comment_count}")
      elsif comment_count <= alarm_count
        last_comment = comments.last
        alarm.update_columns(send_user_id: last_comment.user_id,
                             comment_id: last_comment.id,
                             alarm_type: "comment_#{comment_count}")
      else
        alarm.update(is_read: false,
                     send_user_id: user_id,
                     comment_id: id,
                     alarm_type: "comment_#{comment_count}")
      end
    else
      return if comment_count.zero?
      Alarm.create(user_id: ask.user_id,
                   ask_id: ask.id,
                   send_user_id: user_id,
                   comment_id: id,
                   alarm_type: "comment_#{comment_count}")
    end
  end
  handle_asynchronously :create_comment_alarm

  # 본인의 댓글에 대한 대댓글 알림 (alarm_5, type: reply_comment)
  def create_reply_comment_alarm
    return if comment_id.nil?

    ask = self.ask

    return if user_id == original_comment.user_id || original_comment.user_id == ask.user_id
    return unless original_comment.user.alarm_5

    reply_comments = Comment.where(comment_id: comment_id,
                                   is_deleted: false)
                            .where.not(user_id: original_comment.user_id)
    comment_count = reply_comments.count

    alarm = Alarm.where(user_id: original_comment.user_id,
                        original_comment_id: original_comment.id)
                 .where('alarm_type LIKE ?', 'reply_comment_%').first

    if alarm
      alarm_count = alarm.alarm_type.delete('reply_comment_').to_i
      if comment_count.zero?
        alarm.update_columns(user_id: nil,
                             alarm_type: "reply_comment_#{comment_count}")
      elsif comment_count <= alarm_count
        last_comment = reply_comments.last
        alarm.update_columns(send_user_id: last_comment.user_id,
                             comment_id: last_comment.id,
                             alarm_type: "reply_comment_#{comment_count}")
      else
        alarm.update(is_read: false,
                     send_user_id: user_id,
                     comment_id: id,
                     alarm_type: "reply_comment_#{comment_count}")
      end
    else
      return if comment_count.zero?
      Alarm.create(user_id: original_comment.user_id,
                   ask_id: ask.id,
                   original_comment_id: original_comment.id,
                   send_user_id: user_id,
                   comment_id: id,
                   alarm_type: "reply_comment_#{comment_count}")
    end
  end
  handle_asynchronously :create_reply_comment_alarm

  # 본인이 댓글을 작성한 질문에 대한 추가 댓글 알림 (alarm_6, type: sub_comment)
  def create_sub_comment_alarm
    ask = self.ask
    prev_comments = Comment.where(ask_id: ask.id, is_deleted: false)
                           .where.not(user_id: user_id)
                           .where.not(user_id: ask.user_id)
                           .where("id < #{id}")
                           .uniq

    prev_comments.each do |prev_comment|
      next if !comment_id.nil? && comment_id == prev_comment.id
      next unless prev_comment.user.alarm_6
      sub_comments = Comment.where(ask_id: ask.id, is_deleted: false)
                            .where.not(user_id: prev_comment.user_id)
                            .where("id > #{prev_comment.id}")
      comment_count = sub_comments.count

      alarm = Alarm.where(user_id: prev_comment.user_id,
                          ask_id: ask.id)
                   .where('alarm_type LIKE ?', 'sub_comment_%').first

      if alarm
         alarm_count = alarm.alarm_type.delete('sub_comment_').to_i
         if comment_count.zero?
           alarm.update_columns(user_id: nil,
                                alarm_type: "sub_comment_#{comment_count}")
         elsif comment_count <= alarm_count
           last_comment = sub_comments.last
           alarm.update_columns(send_user_id: last_comment.user_id,
                                comment_id: last_comment.id,
                                alarm_type: "sub_comment_#{comment_count}")
         else
           alarm.update(is_read: false,
                        send_user_id: user_id,
                        comment_id: id,
                        alarm_type: "sub_comment_#{comment_count}")
         end
      else
         next if comment_count.zero?
         Alarm.create(user_id: prev_comment.user_id,
                      ask_id: ask.id,
                      ask_owner_user_id: ask.user_id,
                      send_user_id: user_id,
                      comment_id: id,
                      alarm_type: "sub_comment_#{comment_count}")
      end
    end
  end
  handle_asynchronously :create_sub_comment_alarm

  # 본인이 대댓글을 작성한 댓글에 대한 추가 대댓글 알림 (alarm_6, type: reply_sub_comment)
  def create_reply_sub_comment_alarm
    return if comment_id.nil?

    ask = self.ask
    prev_reply_comments = Comment.where(ask_id: ask.id, comment_id: comment_id, is_deleted: false)
                                 .where.not(user_id: user_id)
                                 .where.not(user_id: ask.user_id)
                                 .where.not(user_id: original_comment.user_id)
                                 .where("id < #{id}")
                                 .uniq

    prev_reply_comments.each do |prev_reply_comment|
      next unless prev_reply_comment.user.alarm_6
      reply_sub_comments = Comment.where(ask_id: ask.id, comment_id: comment_id, is_deleted: false)
                                  .where.not(user_id: prev_reply_comment.user_id)
                                  .where("id > #{prev_reply_comment.id}")
      comment_count = reply_sub_comments.count

      alarm = Alarm.where(user_id: prev_reply_comment.user_id,
                          original_comment_id: original_comment.id)
                   .where('alarm_type LIKE ?', 'reply_sub_comment_%').first

      if alarm
        alarm_count = alarm.alarm_type.delete('reply_sub_comment_').to_i
        if comment_count.zero?
          alarm.update_columns(user_id: nil,
                               alarm_type: "reply_sub_comment_#{comment_count}")
        elsif comment_count <= alarm_count
          last_comment = reply_sub_comments.last
          alarm.update_columns(send_user_id: last_comment.user_id,
                               comment_id: last_comment.id,
                               alarm_type: "reply_sub_comment_#{comment_count}")
        else
          alarm.update(is_read: false,
                       send_user_id: user_id,
                       comment_id: id,
                       alarm_type: "reply_sub_comment_#{comment_count}")
        end
      else
        next if comment_count.zero?
        Alarm.create(user_id: prev_reply_comment.user_id,
                     ask_id: ask.id,
                     original_comment_id: original_comment.id,
                     comment_owner_user_id: original_comment.user_id,
                     send_user_id: user_id,
                     comment_id: id,
                     alarm_type: "reply_sub_comment_#{comment_count}")
      end
    end

  end
  handle_asynchronously :create_reply_sub_comment_alarm

  # 본인이 공감한 질문에 추가 댓글 알림 (alarm_7, type: liked_ask_comment)
  def create_liked_ask_comment_alarm
    ask = self.ask
    like_asks = AskLike.where(ask_id: ask_id)

    like_asks.each do |like_ask|
      next if user_id == like_ask.user_id
      next unless like_ask.user.alarm_7
      comments = Comment.where(ask_id: ask_id,
                               is_deleted: false)
                        .where.not(user_id: like_ask.user_id)
      comment_count = comments.count

      alarm = Alarm.where(user_id: like_ask.user_id,
                          ask_id: ask_id)
                   .where('alarm_type LIKE ?', 'liked_ask_comment_%').first

      if alarm
        alarm_count = alarm.alarm_type.delete('liked_ask_comment_').to_i
        if comment_count.zero?
          alarm.update_columns(user_id: nil,
                               alarm_type: "liked_ask_comment_#{comment_count}")
        elsif comment_count <= alarm_count
          last_comment = comments.last
          alarm.update_columns(send_user_id: last_comment.user_id,
                               comment_id: last_comment.id,
                               alarm_type: "liked_ask_comment_#{comment_count}")
        else
          alarm.update(is_read: false,
                       send_user_id: user_id,
                       comment_id: id,
                       alarm_type: "liked_ask_comment_#{comment_count}")
        end
      else
        return if comment_count.zero?
        Alarm.create(user_id: like_ask.user_id,
                     ask_id: ask.id,
                     ask_owner_user_id: ask.user_id,
                     send_user_id: user_id,
                     comment_id: id,
                     alarm_type: "liked_ask_comment_#{comment_count}")
      end
    end
  end
  handle_asynchronously :create_liked_ask_comment_alarm
end
