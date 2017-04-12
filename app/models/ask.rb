class Ask < ActiveRecord::Base
  include SlackNotifier

  ASK_PER = 5

  belongs_to :user
  belongs_to :left_ask_deal, class_name: 'AskDeal', foreign_key: 'left_ask_deal_id'
  belongs_to :right_ask_deal, class_name: 'AskDeal', foreign_key: 'right_ask_deal_id'
  belongs_to :category
  belongs_to :event
  has_one :ask_complete
  has_many :votes
  has_many :ask_likes
  has_many :hash_tags
  has_many :comments
  has_many :original_comments, -> { original_comments }, class_name: 'Comment', foreign_key: 'ask_id'
  has_many :share_logs
  has_many :alarms
  has_many :collection_to_asks
  has_many :collections, through: :collection_to_asks

  def fetch_ask_detail
    as_json(include: [{ user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } },
                      :left_ask_deal,
                      :right_ask_deal,
                      :votes,
                      { ask_likes: { include: { user: { only: [:id, :string_id] } } } },
                      :ask_complete])
  end

  def alarm_read(user_id)
    new_alarms = alarms.where(user_id: user_id, is_read: false)
    return if new_alarms.blank?
    last_alarm = new_alarms.last
    new_alarms.update_all(is_read: true)
    last_alarm.record_timestamps = false
    last_alarm.update(is_read: true)
    last_alarm.record_timestamps = true
  end

  def detail_vote_count
    age_20 = Date.new(Time.now.year - 18, 1, 1)
    age_20_1_end = Date.new(Time.now.year - 22, 1, 1)
    age_20_2_end = Date.new(Time.now.year - 25, 1, 1)
    age_30 = Date.new(Time.now.year - 28, 1, 1)
    age_30_1_end = Date.new(Time.now.year - 32, 1, 1)
    age_30_2_end = Date.new(Time.now.year - 35, 1, 1)
    age_30_3_end = Date.new(Time.now.year - 38, 1, 1)

    ask_votes = Vote.joins('JOIN users ON votes.user_id = users.id')
    left_votes = ask_votes.where("votes.ask_deal_id = #{left_ask_deal_id}")
    right_votes = ask_votes.where("votes.ask_deal_id = #{right_ask_deal_id}")

    {
      left: {
        male_count: left_votes.where('users.gender = true').count,
        female_count: left_votes.where('users.gender = false').count,
        age_20_1_count: left_votes.where("users.birthday < '#{age_20}' AND users.birthday > '#{age_20_1_end}'").count,
        age_20_2_count: left_votes.where("users.birthday < '#{age_20_1_end}' AND users.birthday > '#{age_20_2_end}'").count,
        age_20_3_count: left_votes.where("users.birthday < '#{age_20_2_end}' AND users.birthday > '#{age_30}'").count,
        age_30_1_count: left_votes.where("users.birthday < '#{age_30}' AND users.birthday > '#{age_30_1_end}'").count,
        age_30_2_count: left_votes.where("users.birthday < '#{age_30_1_end}' AND users.birthday > '#{age_30_2_end}'").count,
        age_30_3_count: left_votes.where("users.birthday < '#{age_30_2_end}' AND users.birthday > '#{age_30_3_end}'").count,
        etc_count: left_votes.where("users.birthday IS NULL OR (users.birthday > '#{age_20}' OR users.birthday < '#{age_30_3_end}')").count
      },
      right: {
        male_count: right_votes.where('users.gender = true').count,
        female_count: right_votes.where('users.gender = false').count,
        age_20_1_count: right_votes.where("users.birthday < '#{age_20}' AND users.birthday > '#{age_20_1_end}'").count,
        age_20_2_count: right_votes.where("users.birthday < '#{age_20_1_end}' AND users.birthday > '#{age_20_2_end}'").count,
        age_20_3_count: right_votes.where("users.birthday < '#{age_20_2_end}' AND users.birthday > '#{age_30}'").count,
        age_30_1_count: right_votes.where("users.birthday < '#{age_30}' AND users.birthday > '#{age_30_1_end}'").count,
        age_30_2_count: right_votes.where("users.birthday < '#{age_30_1_end}' AND users.birthday > '#{age_30_2_end}'").count,
        age_30_3_count: right_votes.where("users.birthday < '#{age_30_2_end}' AND users.birthday > '#{age_30_3_end}'").count,
        etc_count: right_votes.where("users.birthday IS NULL OR (users.birthday > '#{age_20}' OR users.birthday < '#{age_30_3_end}')").count
      }
    }
  end

  def generate_hash_tags
    HashTag.destroy_all(ask_id: id)
    # 업데이트의 경우 기존 해시태그를 모두 삭제한 후 재설정
    hash_tags = message.scan(/#[0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]+/)
    hash_tags.each do |hash_tag|
      hash_tag = hash_tag.tr('#', '').tr(',', '')
      HashTag.create(ask_id: id, user_id: user_id, keyword: hash_tag)
    end
  end
  handle_asynchronously :generate_hash_tags

  def ask_notifier(type)
    return unless user.user_role == 'user'
    noti_channel = YAML.load_file(Rails.root.join('config/slack.yml'))[Rails.env]['ask_channel']
    noti_title = "[#{id}번](#{CONFIG['host']}/asks/#{id})"
    noti_message = "- 작성자 : #{user.string_id} (#{(user.gender == true ? '남성' : '여성')}, #{(Time.now.year - user.birthday.year + 1)}세)"
    if type == 'new'
      noti_title += ' / 새로운 질문이 작성되었습니다'
      noti_color = '#FF7200'
      noti_message += "\n- #{((Time.now - user.created_at) / 60 / 60 / 24).to_i}일 전 가입자"
      noti_message += " / #{Ask.where(user_id: user_id).count}번째 작성한 질문"
    elsif type == 'edit'
      noti_title += ' / 사용자가 질문을 수정하였습니다'
      noti_color = '#666666'
      noti_message += "\n- #{((Time.now - created_at) / 60 / 60 / 24).to_i}일 전 작성된 질문"
    elsif type == 'complete'
      noti_title += ' / 사용자가 질문을 종료하였습니다'
      noti_message += "\n- 투표 #{(left_ask_deal.vote_count + right_ask_deal.vote_count)}표"
      noti_message += " / 댓글 #{(left_ask_deal.comment_count + right_ask_deal.comment_count)}개"
      noti_message += " / 공감 #{like_count}회"
      noti_message += "\n- 만족도 별점 #{ask_complete.star_point}점"
      noti_color = '#333333'
    end
    noti_message += "\n- 내용\n#{message}"

    slack_notifier(noti_channel, noti_title, noti_message, noti_color)

    return unless type == 'new'
    noti_channel = YAML.load_file(Rails.root.join('config/slack.yml'))[Rails.env]['alba_channel']
    noti_title = '새로운 질문이 작성되었습니다! 댓글을 작성해주세요 :)'
    noti_title += "\n[질문으로 이동](#{CONFIG['host']}/asks/#{id})"
    noti_message = message.to_s
    noti_color = '#FF7200'
    slack_notifier(noti_channel, noti_title, noti_message, noti_color)
  end
  handle_asynchronously :ask_notifier
end
