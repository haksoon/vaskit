module SlackNotifier
  require 'slack-notifier'
  WEBHOOK_URL = YAML.load_file(Rails.root.join('config/slack.yml'))['webhook_url']

  def slack_notifier(channel, title, message, color)
    notifier = Slack::Notifier.new WEBHOOK_URL, channel: channel
    color = 'good' if color.nil?
    notifier.post text: title,
                  fallback: title,
                  attachments: [{
                    fallback: title,
                    text: message,
                    color: color
                  }]
  end

  def slack_notifier_alba(channel, title, message, color)
    notifier = Slack::Notifier.new WEBHOOK_URL, channel: channel
    color = 'good' if color.nil?
    notifier.post text: title,
                  fallback: title,
                  attachments: [{
                    fallback: title,
                    text: message,
                    color: color
                  }]
  end

  def self.slack_notifier_daily_summary
    channel = YAML.load_file(Rails.root.join('config/slack.yml'))[Rails.env]['daily_channel']
    notifier = Slack::Notifier.new WEBHOOK_URL, channel: channel

    now = Time.now - 3600 # 1시간 빼줌
    date = now.strftime('%Y년 %m월 %d일')
    start_time = DateTime.new(now.year, now.month, now.day - 1, 15, 0, 0)
    end_time = DateTime.new(now.year, now.month, now.day, 15, 0, 0)

    active_user_count = UserVisit.joins(:user).where('users.user_role = "user"').where('user_visits.created_at > ? AND user_visits.created_at < ?', start_time, end_time).pluck('user_visits.user_id').uniq.count
    visit_count = UserVisit.where('created_at > ? AND created_at < ?', start_time, end_time).pluck(:visitor_id).uniq.count
    signup_count = User.where('created_at > ? AND created_at < ?', start_time, end_time).count
    vote_count = Vote.joins(:user).where('users.user_role = "user"').where('votes.created_at > ? AND votes.created_at < ?', start_time, end_time).count
    comment_count = Comment.joins(:user).where('users.user_role = "user"').where('comments.created_at > ? AND comments.created_at < ?', start_time, end_time).count
    ask_count = Ask.joins(:user).where('users.user_role = "user"').where('asks.created_at > ? AND asks.created_at < ?', start_time, end_time).count
    ask_like_count = AskLike.joins(:user).where('users.user_role = "user"').where('ask_likes.created_at > ? AND ask_likes.created_at < ?', start_time, end_time).count
    comment_like_count = CommentLike.joins(:user).where('users.user_role = "user"').where('comment_likes.created_at > ? AND comment_likes.created_at < ?', start_time, end_time).count
    share_count = ShareLog.joins(:user).where('users.user_role = "user"').where('share_logs.created_at > ? AND share_logs.created_at < ?', start_time, end_time).count

    title = "*#{date} 일일 리포트*"
    message = ''
    message += "오늘의 신규 가입자는 `#{signup_count}명`이고, 활성 회원수는 `#{active_user_count}명`입니다"
    message += "\n비회원 등을 포함한 전체 방문자는 총 `#{visit_count}명`입니다"
    message += "\n투표 `#{vote_count}회`, 댓글 `#{comment_count}개`, 질문 `#{ask_count}개`,"
    message += "\n공감해요 `#{ask_like_count}회`, 댓글 좋아요 `#{comment_like_count}회`, 공유 `#{share_count}회`의 활동이력이 있습니다"
    message += "\n[어드민 페이지로 이동](http://vaskit.kr/admin/analysis)"
    color = 'good'
    notifier.post text: title,
                  attachments: [{
                    color: color,
                    text: message,
                    mrkdwn_in: ['text']
                  }]
  end
end
