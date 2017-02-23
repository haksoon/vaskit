class Admin::AnalysisController < Admin::HomeController
  # GET /admin/analysis
  def index
    @types = { daily: '일자별 지표 분석',
               weekly: '주간별 지표 분석',
               monthly: '월간별 지표 분석',
               asks: '질문 추이 분석',
               users: '사용자별 분석' }
    if params[:type].nil?
      @title = '주요 누적 지표 (2017년 7월부터 집계)'
      admin_user_ids = User.where(user_role: 'admin').pluck(:id)
      alba_user_ids = User.where(user_role: 'alba').pluck(:id)
      @total_visit_count = UserVisit.count
      @total_vote_count = Vote.count
      @total_comment_count = Comment.count
      @total_ask_count = Ask.count
      @total_user_count = User.count
      @admin_visit_count = UserVisit.where(user_id: admin_user_ids).count
      @admin_vote_count = Vote.where(user_id: admin_user_ids).count
      @admin_comment_count = Comment.where(user_id: admin_user_ids).count
      @admin_ask_count = Ask.where(user_id: admin_user_ids).count
      @admin_user_count = User.where(id: admin_user_ids).count
      @alba_visit_count = UserVisit.where(user_id: alba_user_ids).count
      @alba_vote_count = Vote.where(user_id: alba_user_ids).count
      @alba_comment_count = Comment.where(user_id: alba_user_ids).count
      @alba_ask_count = Ask.where(user_id: alba_user_ids).count
      @alba_user_count = User.where(id: alba_user_ids).count
      @real_visit_count = @total_visit_count - @admin_visit_count - @alba_visit_count
      @real_vote_count = @total_vote_count - @admin_vote_count - @alba_vote_count
      @real_comment_count = @total_comment_count - @admin_comment_count - @alba_comment_count
      @real_ask_count = @total_ask_count - @admin_ask_count - @alba_ask_count
      @real_user_count = @total_user_count - @admin_user_count - @alba_user_count
    elsif params[:type] == 'daily'
      @title = '일간 분석'
      @summaries = Vote.find_by_sql(<<-SQL.squish)
        SELECT date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') AS period,
          IFNULL(SU.signup_count, 0) AS 'signup_count',
          IFNULL(AU.DAU, 0) AS 'active_user',
          IFNULL(UV.visit_count, 0) AS 'visit_count',
          IFNULL(V.vote_count, 0) AS 'vote_count',
          IFNULL(C.comment_count, 0) AS 'comment_count',
          IFNULL(A.ask_count, 0) AS 'ask_count',
          IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
          IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
          IFNULL(SL.share_count, 0) AS 'share_count'
        FROM `votes`
          LEFT JOIN v_daily_signups SU ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = SU.date
          LEFT JOIN v_daily_active AU ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = AU.date
          LEFT JOIN v_daily_visits UV ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = UV.date
          LEFT JOIN v_daily_votes V ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = V.date
          LEFT JOIN v_daily_comments C ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = C.date
          LEFT JOIN v_daily_asks A ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = A.date
          LEFT JOIN v_daily_comment_likes CL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = CL.date
          LEFT JOIN v_daily_ask_likes AL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = AL.date
          LEFT JOIN v_daily_shares SL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') = SL.date
        WHERE date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m-%d') BETWEEN ADDDATE(CURDATE(), INTERVAL -9 DAY) AND CURDATE()
        GROUP BY period ORDER BY period DESC
      SQL
    elsif params[:type] == 'weekly'
      @title = '주간 분석'
      @summaries = Vote.find_by_sql(<<-SQL.squish)
        SELECT date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') AS period,
          IFNULL(SU.signup_count, 0) AS 'signup_count',
          IFNULL(AU.WAU, 0) AS 'active_user',
          IFNULL(UV.visit_count, 0) AS 'visit_count',
          IFNULL(V.vote_count, 0) AS 'vote_count',
          IFNULL(C.comment_count, 0) AS 'comment_count',
          IFNULL(A.ask_count, 0) AS 'ask_count',
          IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
          IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
          IFNULL(SL.share_count, 0) AS 'share_count'
        FROM `votes`
          LEFT JOIN v_weekly_signups SU ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = SU.week
          LEFT JOIN v_weekly_active AU ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = AU.week
          LEFT JOIN v_weekly_visits UV ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = UV.week
          LEFT JOIN v_weekly_votes V ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = V.week
          LEFT JOIN v_weekly_comments C ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = C.week
          LEFT JOIN v_weekly_asks A ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = A.week
          LEFT JOIN v_weekly_comment_likes CL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = CL.week
          LEFT JOIN v_weekly_ask_likes AL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = AL.week
          LEFT JOIN v_weekly_shares SL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') = SL.week
        WHERE date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%u') BETWEEN date_format(ADDDATE(CURDATE(), INTERVAL -9 WEEK), '%Y-%u') AND date_format(CURDATE(), '%Y-%u')
        GROUP BY period ORDER BY period DESC
      SQL
    elsif params[:type] == 'monthly'
      @title = '월간 분석'
      @summaries = Vote.find_by_sql(<<-SQL.squish)
        SELECT date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') AS period,
          IFNULL(SU.signup_count, 0) AS 'signup_count',
          IFNULL(AU.MAU, 0) AS 'active_user',
          IFNULL(UV.visit_count, 0) AS 'visit_count',
          IFNULL(V.vote_count, 0) AS 'vote_count',
          IFNULL(C.comment_count, 0) AS 'comment_count',
          IFNULL(A.ask_count, 0) AS 'ask_count',
          IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
          IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
          IFNULL(SL.share_count, 0) AS 'share_count'
        FROM `votes`
          LEFT JOIN v_monthly_signups SU ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = SU.month
          LEFT JOIN v_monthly_active AU ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = AU.month
          LEFT JOIN v_monthly_visits UV ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = UV.month
          LEFT JOIN v_monthly_votes V ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = V.month
          LEFT JOIN v_monthly_comments C ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = C.month
          LEFT JOIN v_monthly_asks A ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = A.month
          LEFT JOIN v_monthly_comment_likes CL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = CL.month
          LEFT JOIN v_monthly_ask_likes AL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = AL.month
          LEFT JOIN v_monthly_shares SL ON date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') = SL.month
        WHERE date_format(addtime(`votes`.created_at, '09:00:00'), '%Y-%m') BETWEEN date_format(ADDDATE(CURDATE(), INTERVAL -9 MONTH), '%Y-%m') AND date_format(CURDATE(), '%Y-%m')
        GROUP BY period ORDER BY period DESC
      SQL
    elsif params[:type] == 'asks'
      @title = '회원 작성 질문 분석'
      @asks = Ask.find_by_sql(<<-SQL.squish)
        SELECT `asks`.id AS 'ask_id', `asks`.message, date_format(addtime(`asks`.created_at, '09:00:00'), '%Y-%m-%d') AS 'created_at',
          IFNULL(V.vote_count, 0) AS 'vote_count',
          IFNULL(C.comment_count, 0) AS 'comment_count',
          IFNULL(CO.comment_others_count, 0) AS 'comment_others_count',
          IFNULL(CM.comment_my_count, 0) AS 'comment_my_count',
          IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
          IFNULL(SL.share_count, 0) AS 'share_count'
        FROM `asks`
          LEFT JOIN v_ask_votes V ON `asks`.id = V.ask_id
          LEFT JOIN v_ask_comments C ON `asks`.id = C.ask_id
          LEFT JOIN v_ask_comments_others CO ON `asks`.id = CO.ask_id
          LEFT JOIN v_ask_comments_my CM ON `asks`.id = CM.ask_id
          LEFT JOIN v_ask_likes AL ON `asks`.id = AL.ask_id
          LEFT JOIN v_ask_shares SL ON `asks`.id = SL.ask_id
          LEFT JOIN users U ON U.id = `asks`.user_id
        WHERE U.user_role = 'user'
          AND date_format(addtime(`asks`.created_at, '09:00:00'), '%Y-%m-%d') BETWEEN ADDDATE(CURDATE(), INTERVAL -9 DAY) AND CURDATE()
        ORDER BY ask_id DESC
      SQL
    elsif params[:type] == 'users'
      @title = '회원별 분석'
      @users = User.find_by_sql(<<-SQL.squish)
        SELECT U.id AS 'user_id', U.email, U.string_id, U.name, date_format(addtime(U.created_at, '09:00:00'), '%Y-%m-%d') AS 'created_at', date_format(UV.recent_visit, '%Y-%m-%d') AS 'recent_visit',
          IFNULL(UV.visit_count, 0) AS 'visit_count',
          IFNULL(V.vote_count, 0) AS 'vote_count',
          IFNULL(C.comment_count, 0) AS 'comment_count',
          IFNULL(A.ask_count, 0) AS 'ask_count',
          IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
          IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
          IFNULL(SL.share_count, 0) AS 'share_count'
        FROM users U
          LEFT JOIN v_user_visits UV ON U.id = UV.user_id
          LEFT JOIN v_user_votes V ON U.id = V.user_id
          LEFT JOIN v_user_comments C ON U.id = C.user_id
          LEFT JOIN v_user_asks A ON U.id = A.user_id
          LEFT JOIN v_user_comment_likes CL ON U.id = CL.user_id
          LEFT JOIN v_user_ask_likes AL ON U.id = AL.user_id
          LEFT JOIN v_user_shares SL ON U.id = SL.user_id
        WHERE U.user_role = 'user'
        ORDER BY visit_count DESC
      SQL
    end
  end
end
