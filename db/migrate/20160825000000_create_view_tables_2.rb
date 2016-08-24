class CreateViewTables2 < ActiveRecord::Migration
  def up
    ############################################################################ 종합 조회 ############################################################################

    # 유저별 분석 종합
    self.connection.execute """
    CREATE VIEW view_users AS
      SELECT U.id AS 'user_id', U.email, U.string_id, U.name, date_format(addtime(U.created_at, '09:00:00'), '%Y-%m-%d') AS 'created_at',
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
      ORDER BY visit_count DESC;
    """

    # 일자별 분석 종합
    self.connection.execute """
    CREATE VIEW view_daily AS
        SELECT UV.date,
        	IFNULL(SU.signup_count, 0) AS 'signup_count',
        	IFNULL(AU.DAU, 0) AS 'DAU',
        	IFNULL(UV.visit_count, 0) AS 'visit_count',
        	IFNULL(V.vote_count, 0) AS 'vote_count',
        	IFNULL(C.comment_count, 0) AS 'comment_count',
        	IFNULL(A.ask_count, 0) AS 'ask_count',
        	IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
        	IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
        	IFNULL(SL.share_count, 0) AS 'share_count'
        FROM v_daily_visits UV
        	LEFT JOIN v_daily_signups SU ON UV.date = SU.date
        	LEFT JOIN v_daily_active AU ON UV.date = AU.date
        	LEFT JOIN v_daily_votes V ON UV.date = V.date
        	LEFT JOIN v_daily_comments C ON UV.date = C.date
        	LEFT JOIN v_daily_asks A ON UV.date = A.date
        	LEFT JOIN v_daily_comment_likes CL ON UV.date = CL.date
        	LEFT JOIN v_daily_ask_likes AL ON UV.date = AL.date
        	LEFT JOIN v_daily_shares SL ON UV.date = SL.date
        ORDER BY UV.date DESC;
    """

    # 주간별 분석 종합
    self.connection.execute """
    CREATE VIEW view_weekly AS
      SELECT V.week,
      	IFNULL(SU.signup_count, 0) AS 'signup_count',
      	IFNULL(AU.WAU, 0) AS 'WAU',
      	IFNULL(UV.visit_count, 0) AS 'visit_count',
      	IFNULL(V.vote_count, 0) AS 'vote_count',
      	IFNULL(C.comment_count, 0) AS 'comment_count',
      	IFNULL(A.ask_count, 0) AS 'ask_count',
      	IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
      	IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
      	IFNULL(SL.share_count, 0) AS 'share_count'
      FROM v_weekly_votes V
      	LEFT JOIN v_weekly_signups SU ON V.week = SU.week
      	LEFT JOIN v_weekly_active AU ON V.week = AU.week
      	LEFT JOIN v_weekly_visits UV ON V.week = UV.week
      	LEFT JOIN v_weekly_comments C ON V.week = C.week
      	LEFT JOIN v_weekly_asks A ON V.week = A.week
      	LEFT JOIN v_weekly_comment_likes CL ON V.week = CL.week
      	LEFT JOIN v_weekly_ask_likes AL ON V.week = AL.week
      	LEFT JOIN v_weekly_shares SL ON V.week = SL.week
      ORDER BY V.week DESC;
    """

    # 월별 분석 종합
    self.connection.execute """
    CREATE VIEW view_monthly AS
      SELECT V.month,
      	IFNULL(SU.signup_count, 0) AS 'signup_count',
      	IFNULL(AU.MAU, 0) AS 'MAU',
      	IFNULL(UV.visit_count, 0) AS 'visit_count',
      	IFNULL(V.vote_count, 0) AS 'vote_count',
      	IFNULL(C.comment_count, 0) AS 'comment_count',
      	IFNULL(A.ask_count, 0) AS 'ask_count',
      	IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
      	IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
      	IFNULL(SL.share_count, 0) AS 'share_count'
      FROM v_monthly_votes V
      	LEFT JOIN v_monthly_signups SU ON V.month = SU.month
      	LEFT JOIN v_monthly_active AU ON V.month = AU.month
      	LEFT JOIN v_monthly_visits UV ON V.month = UV.month
      	LEFT JOIN v_monthly_comments C ON V.month = C.month
      	LEFT JOIN v_monthly_asks A ON V.month = A.month
      	LEFT JOIN v_monthly_comment_likes CL ON V.month = CL.month
      	LEFT JOIN v_monthly_ask_likes AL ON V.month = AL.month
      	LEFT JOIN v_monthly_shares SL ON V.month = SL.month
      ORDER BY V.month DESC;
    """

    # 게시글별 분석 종합
    self.connection.execute """
    CREATE VIEW view_asks AS
      SELECT A.id AS 'ask_id', A.message, date_format(addtime(A.created_at, '09:00:00'), '%Y-%m-%d') AS 'created_at',
      	IFNULL(V.vote_count, 0) AS 'vote_count',
      	IFNULL(C.comment_count, 0) AS 'comment_count',
      	IFNULL(CO.comment_others_count, 0) AS 'comment_others_count',
      	IFNULL(CM.comment_my_count, 0) AS 'comment_my_count',
      	IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
      	IFNULL(SL.share_count, 0) AS 'share_count'
      FROM asks A
      	LEFT JOIN v_ask_votes V ON A.id = V.ask_id
      	LEFT JOIN v_ask_comments C ON A.id = C.ask_id
      	LEFT JOIN v_ask_comments_others CO ON A.id = CO.ask_id
      	LEFT JOIN v_ask_comments_my CM ON A.id = CM.ask_id
      	LEFT JOIN v_ask_likes AL ON A.id = AL.ask_id
      	LEFT JOIN v_ask_shares SL ON A.id = SL.ask_id
      	LEFT JOIN users U ON U.id = A.user_id
    	WHERE U.user_role = 'user'
      ORDER BY vote_count DESC;
    """

    # 유저별 분석 종합 (아르바이트)
    self.connection.execute """
    CREATE VIEW view_alba AS
      SELECT U.id AS 'user_id', U.email, U.string_id, U.name, date_format(addtime(U.created_at, '09:00:00'), '%Y-%m-%d') AS 'created_at', UV.visit_count, V.vote_count, C.comment_count, A.ask_count, CL.comment_like_count, AL.ask_like_count, SL.share_count
      FROM users U
      	LEFT JOIN v_alba_visits UV ON U.id = UV.user_id
      	LEFT JOIN v_alba_votes V ON U.id = V.user_id
      	LEFT JOIN v_alba_comments C ON U.id = C.user_id
      	LEFT JOIN v_alba_asks A ON U.id = A.user_id
      	LEFT JOIN v_alba_comment_likes CL ON U.id = CL.user_id
      	LEFT JOIN v_alba_ask_likes AL ON U.id = AL.user_id
      	LEFT JOIN v_alba_shares SL ON U.id = SL.user_id
      WHERE U.user_role = 'alba'
      GROUP BY U.id ORDER BY visit_count DESC;
    """

    # 일자별 분석 종합 (아르바이트)
    self.connection.execute """
    CREATE VIEW view_alba_daily AS
      SELECT UV.date,
      	IFNULL(UV.visit_count, 0) AS 'visit_count',
      	IFNULL(V.vote_count, 0) AS 'vote_count',
      	IFNULL(C.comment_count, 0) AS 'comment_count',
      	IFNULL(A.ask_count, 0) AS 'ask_count',
      	IFNULL(CL.comment_like_count, 0) AS 'comment_like_count',
      	IFNULL(AL.ask_like_count, 0) AS 'ask_like_count',
      	IFNULL(SL.share_count, 0) AS 'share_count'
      FROM v_alba_daily_visits UV
      	LEFT JOIN v_alba_daily_votes V ON UV.date = V.date
      	LEFT JOIN v_alba_daily_comments C ON UV.date = C.date
      	LEFT JOIN v_alba_daily_asks A ON UV.date = A.date
      	LEFT JOIN v_alba_daily_comment_likes CL ON UV.date = CL.date
      	LEFT JOIN v_alba_daily_ask_likes AL ON UV.date = AL.date
      	LEFT JOIN v_alba_daily_shares SL ON UV.date = SL.date
      ORDER BY UV.date DESC;
    """

  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS view_users;"
    self.connection.execute "DROP VIEW IF EXISTS view_daily;"
    self.connection.execute "DROP VIEW IF EXISTS view_weekly;"
    self.connection.execute "DROP VIEW IF EXISTS view_montly;"
    self.connection.execute "DROP VIEW IF EXISTS view_asks;"
    self.connection.execute "DROP VIEW IF EXISTS view_alba;"
    self.connection.execute "DROP VIEW IF EXISTS view_alba_daily;"
  end
end
