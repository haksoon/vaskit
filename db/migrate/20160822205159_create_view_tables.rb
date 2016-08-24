class CreateViewTables < ActiveRecord::Migration
  def up
    ############################################################################ 유저별 ############################################################################
    # 유저별 방문 횟수 (UV, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_user_visits AS
    	SELECT U.id AS 'user_id', count(UV.id) AS 'visit_count'
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 투표 횟수 (V, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_user_votes AS
    	SELECT U.id AS 'user_id', count(V.id) AS 'vote_count'
    	FROM users U
    		INNER JOIN votes V ON U.id = V.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 댓글 횟수 (C, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_user_comments AS
    	SELECT U.id AS 'user_id', count(C.id) AS 'comment_count'
    	FROM users U
    		INNER JOIN comments C ON U.id = C.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 질문 횟수 (A, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_user_asks AS
    	SELECT U.id AS 'user_id', count(A.id) AS 'ask_count'
    	FROM users U
    		INNER JOIN asks A ON U.id = A.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 의견좋아요 횟수 (CL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_user_comment_likes AS
    	SELECT U.id AS 'user_id', count(CL.id) AS 'comment_like_count'
    	FROM users U
    		INNER JOIN comment_likes CL ON U.id = CL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 질문좋아요 횟수 (AL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_user_ask_likes AS
    	SELECT U.id AS 'user_id', count(AL.id) AS 'ask_like_count'
    	FROM users U
    		INNER JOIN ask_likes AL ON U.id = AL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 공유 횟수 (SL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_user_shares AS
    	SELECT U.id AS 'user_id', count(SL.id) AS 'share_count'
    	FROM users U
    		INNER JOIN share_logs SL ON U.id = SL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """


    ############################################################################ 일자별 ############################################################################
    # 일자별 가입자수
    self.connection.execute """
    CREATE VIEW v_daily_signups AS
    	SELECT date_format(addtime(U.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(U.id) AS 'signup_count'
        FROM users U
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 방문 횟수 (UV, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_visits AS
    	SELECT date_format(addtime(UV.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(UV.id) AS 'visit_count'
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 투표 횟수 (V, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_votes AS
    	SELECT date_format(addtime(V.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(V.id) AS 'vote_count'
    	FROM users U
    		INNER JOIN votes V ON U.id = V.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 댓글 횟수 (C, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_comments AS
    	SELECT date_format(addtime(C.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(C.id) AS 'comment_count'
    	FROM users U
    		INNER JOIN comments C ON U.id = C.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 질문 횟수 (A, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_asks AS
    	SELECT date_format(addtime(A.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(A.id) AS 'ask_count'
    	FROM users U
    		INNER JOIN asks A ON U.id = A.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 의견좋아요 횟수 (CL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_comment_likes AS
    	SELECT date_format(addtime(CL.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(CL.id) AS 'comment_like_count'
    	FROM users U
    		INNER JOIN comment_likes CL ON U.id = CL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 질문좋아요 횟수 (AL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_ask_likes AS
    	SELECT date_format(addtime(AL.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(AL.id) AS 'ask_like_count'
    	FROM users U
    		INNER JOIN ask_likes AL ON U.id = AL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 공유 횟수 (SL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_shares AS
    	SELECT date_format(addtime(SL.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(SL.id) AS 'share_count'
    	FROM users U
    		INNER JOIN share_logs SL ON U.id = SL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY date ORDER BY date DESC;
    """
    # (임시뷰) 유저별 일자별 세션수 (비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_users AS
    	SELECT date_format(addtime(UV.created_at, '09:00:00'), '%Y-%m-%d') AS date, UV.user_id
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY UV.user_id, date ORDER BY date DESC;
    """
    # 일자별 방문 인원수 (DAU, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_daily_active AS
    	SELECT date, count(user_id) as 'DAU'
    	FROM v_daily_users
    	GROUP BY date ORDER BY date DESC;
    """


    ############################################################################ 주간별 ############################################################################
    # 주간별 가입자수
    self.connection.execute """
    CREATE VIEW v_weekly_signups AS
    	SELECT date_format(addtime(U.created_at, '09:00:00'), '%Y-%u') AS week, count(U.id) AS 'signup_count'
        FROM users U
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # 주간별 방문 횟수 (UV, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_visits AS
    	SELECT date_format(addtime(UV.created_at, '09:00:00'), '%Y-%u') AS week, count(UV.id) AS 'visit_count'
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # 주간별 투표 횟수 (V, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_votes AS
    	SELECT date_format(addtime(V.created_at, '09:00:00'), '%Y-%u') AS week, count(V.id) AS 'vote_count'
    	FROM users U
    		INNER JOIN votes V ON U.id = V.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # 주간별 댓글 횟수 (C, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_comments AS
    	SELECT date_format(addtime(C.created_at, '09:00:00'), '%Y-%u') AS week, count(C.id) AS 'comment_count'
    	FROM users U
    		INNER JOIN comments C ON U.id = C.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # 주간별 질문 횟수 (A, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_asks AS
    	SELECT date_format(addtime(A.created_at, '09:00:00'), '%Y-%u') AS week, count(A.id) AS 'ask_count'
    	FROM users U
    		INNER JOIN asks A ON U.id = A.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # 주간별 의견좋아요 횟수 (CL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_comment_likes AS
    	SELECT date_format(addtime(CL.created_at, '09:00:00'), '%Y-%u') AS week, count(CL.id) AS 'comment_like_count'
    	FROM users U
    		INNER JOIN comment_likes CL ON U.id = CL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # 주간별 질문좋아요 횟수 (AL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_ask_likes AS
    	SELECT date_format(addtime(AL.created_at, '09:00:00'), '%Y-%u') AS week, count(AL.id) AS 'ask_like_count'
    	FROM users U
    		INNER JOIN ask_likes AL ON U.id = AL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # 주간별 공유 횟수 (SL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_shares AS
    	SELECT date_format(addtime(SL.created_at, '09:00:00'), '%Y-%u') AS week, count(SL.id) AS 'share_count'
    	FROM users U
    		INNER JOIN share_logs SL ON U.id = SL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY week ORDER BY week DESC;
    """
    # (임시뷰) 유저별 주간별 세션수 (비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_users AS
    	SELECT date_format(addtime(UV.created_at, '09:00:00'), '%Y-%u') AS week, UV.user_id
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY UV.user_id, week ORDER BY week DESC;
    """
    # 주간별 방문 인원수 (WAU, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_weekly_active AS
    	SELECT week, count(user_id) as 'WAU'
    	FROM v_weekly_users
    	GROUP BY week ORDER BY week DESC;
    """


    ############################################################################ 월별 ############################################################################
    # 월별 가입자수
    self.connection.execute """
    CREATE VIEW v_monthly_signups AS
    	SELECT date_format(addtime(U.created_at, '09:00:00'), '%Y-%m') AS month, count(U.id) AS 'signup_count'
        FROM users U
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # 월별 방문 횟수 (UV, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_visits AS
    	SELECT date_format(addtime(UV.created_at, '09:00:00'), '%Y-%m') AS month, count(UV.id) AS 'visit_count'
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # 월별 투표 횟수 (V, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_votes AS
    	SELECT date_format(addtime(V.created_at, '09:00:00'), '%Y-%m') AS month, count(V.id) AS 'vote_count'
    	FROM users U
    		INNER JOIN votes V ON U.id = V.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # 월별 댓글 횟수 (C, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_comments AS
    	SELECT date_format(addtime(C.created_at, '09:00:00'), '%Y-%m') AS month, count(C.id) AS 'comment_count'
    	FROM users U
    		INNER JOIN comments C ON U.id = C.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # 월별 질문 횟수 (A, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_asks AS
    	SELECT date_format(addtime(A.created_at, '09:00:00'), '%Y-%m') AS month, count(A.id) AS 'ask_count'
    	FROM users U
    		INNER JOIN asks A ON U.id = A.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # 월별 의견좋아요 횟수 (CL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_comment_likes AS
    	SELECT date_format(addtime(CL.created_at, '09:00:00'), '%Y-%m') AS month, count(CL.id) AS 'comment_like_count'
    	FROM users U
    		INNER JOIN comment_likes CL ON U.id = CL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # 월별 질문좋아요 횟수 (AL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_ask_likes AS
    	SELECT date_format(addtime(AL.created_at, '09:00:00'), '%Y-%m') AS month, count(AL.id) AS 'ask_like_count'
    	FROM users U
    		INNER JOIN ask_likes AL ON U.id = AL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # 월별 공유 횟수 (SL, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_shares AS
    	SELECT date_format(addtime(SL.created_at, '09:00:00'), '%Y-%m') AS month, count(SL.id) AS 'share_count'
    	FROM users U
    		INNER JOIN share_logs SL ON U.id = SL.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY month ORDER BY month DESC;
    """
    # (임시뷰) 유저별 월별 세션수 (비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_users AS
    	SELECT date_format(addtime(UV.created_at, '09:00:00'), '%Y-%m') AS month, UV.user_id
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY UV.user_id, month ORDER BY month DESC;
    """
    # 월별 방문 인원수 (MAU, 비회원 제외)
    self.connection.execute """
    CREATE VIEW v_monthly_active AS
    	SELECT month, count(user_id) as 'MAU'
    	FROM v_monthly_users
    	GROUP BY month ORDER BY month DESC;
    """


    ############################################################################ 게시글별 ############################################################################
    # 게시글별 누적투표수 (V)
    self.connection.execute """
    CREATE VIEW v_ask_votes AS
    	SELECT A.id AS 'ask_id', count(V.id) AS 'vote_count'
    	FROM asks A
    		LEFT JOIN votes V ON A.id = V.ask_id
    		LEFT JOIN users U ON U.id = A.user_id
    		WHERE U.user_role = 'user'
            GROUP BY A.id ORDER BY count(*) DESC;
    """
    # 게시글별 댓글수 / 전체 (C)
    self.connection.execute """
    CREATE VIEW v_ask_comments AS
    	SELECT A.id AS 'ask_id', count(C.id) AS 'comment_count'
    	FROM asks A
    		LEFT JOIN comments C ON A.id = C.ask_id
    		LEFT JOIN users U ON U.id = A.user_id
            WHERE U.user_role = 'user'
    	GROUP BY A.id ORDER BY count(*) DESC;
    """
    # 게시글별 댓글수 / 본인 제외 (C)
    self.connection.execute """
    CREATE VIEW v_ask_comments_others AS
    	SELECT A.id AS 'ask_id', count(C.id) AS 'comment_others_count'
    	FROM asks A
    		LEFT JOIN comments C ON A.id = C.ask_id
    		LEFT JOIN users U ON U.id = A.user_id
            WHERE U.user_role = 'user' AND C.user_id <> A.user_id
    	GROUP BY A.id ORDER BY count(*) DESC;
    """
    # 게시글별 댓글수 - 본인 댓글 (C)
    self.connection.execute """
    CREATE VIEW v_ask_comments_my AS
    	SELECT A.id AS 'ask_id', count(C.id) AS 'comment_my_count'
    	FROM asks A
    		LEFT JOIN comments C ON A.id = C.ask_id
    		LEFT JOIN users U ON U.id = A.user_id
            WHERE U.user_role = 'user' AND C.user_id = A.user_id
    	GROUP BY A.id ORDER BY count(*) DESC;
    """
    # 게시글별 질문좋아요수 (AL)
    self.connection.execute """
    CREATE VIEW v_ask_likes AS
    	SELECT A.id AS 'ask_id', A.like_count AS 'ask_like_count'
    	FROM asks A
    		LEFT JOIN users U ON U.id = A.user_id
            WHERE U.user_role = 'user'
    	ORDER BY like_count DESC;
    """
    # 게시글별 공유 횟수 (SL)
    self.connection.execute """
    CREATE VIEW v_ask_shares AS
    	SELECT A.id AS 'ask_id', count(SL.id) AS 'share_count'
    	FROM asks A
    		LEFT JOIN share_logs SL ON A.id = SL.ask_id
    		LEFT JOIN users U ON U.id = A.user_id
    		WHERE U.user_role = 'user'
    	GROUP BY A.id ORDER BY count(*) DESC;
    """


    ############################################################################ 아르바이트 유저별 ############################################################################
    # 유저별 방문 횟수 (UV, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_visits AS
    	SELECT U.id AS 'user_id', count(UV.id) AS 'visit_count'
    	FROM users U
    		LEFT JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 투표 횟수 (V, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_votes AS
    	SELECT U.id AS 'user_id', count(V.id) AS 'vote_count'
    	FROM users U
    		LEFT JOIN votes V ON U.id = V.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 댓글 횟수 (C, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_comments AS
    	SELECT U.id AS 'user_id', count(C.id) AS 'comment_count'
    	FROM users U
    		LEFT JOIN comments C ON U.id = C.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 질문 횟수 (A, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_asks AS
    	SELECT U.id AS 'user_id', count(A.id) AS 'ask_count'
    	FROM users U
    		LEFT JOIN asks A ON U.id = A.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 의견좋아요 횟수 (CL, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_comment_likes AS
    	SELECT U.id AS 'user_id', count(CL.id) AS 'comment_like_count'
    	FROM users U
    		LEFT JOIN comment_likes CL ON U.id = CL.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 질문좋아요 횟수 (AL, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_ask_likes AS
    	SELECT U.id AS 'user_id', count(AL.id) AS 'ask_like_count'
    	FROM users U
    		LEFT JOIN ask_likes AL ON U.id = AL.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """
    # 유저별 공유 횟수 (SL, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_shares AS
    	SELECT U.id AS 'user_id', count(SL.id) AS 'share_count'
    	FROM users U
    		LEFT JOIN share_logs SL ON U.id = SL.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY U.id ORDER BY count(*) DESC;
    """


    ############################################################################ 아르바이트 일자별 ############################################################################
    # 일자별 방문 횟수 (UV, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_daily_visits AS
    	SELECT date_format(addtime(UV.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(UV.id) AS 'visit_count'
    	FROM users U
    		INNER JOIN user_visits UV ON U.id = UV.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 투표 횟수 (V, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_daily_votes AS
    	SELECT date_format(addtime(V.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(V.id) AS 'vote_count'
    	FROM users U
    		INNER JOIN votes V ON U.id = V.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 댓글 횟수 (C, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_daily_comments AS
    	SELECT date_format(addtime(C.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(C.id) AS 'comment_count'
    	FROM users U
    		INNER JOIN comments C ON U.id = C.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 질문 횟수 (A, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_daily_asks AS
    	SELECT date_format(addtime(A.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(A.id) AS 'ask_count'
    	FROM users U
    		INNER JOIN asks A ON U.id = A.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY date ORDER BY date DESC;
  	"""
    # 일자별 의견좋아요 횟수 (CL, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_daily_comment_likes AS
    	SELECT date_format(addtime(CL.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(CL.id) AS 'comment_like_count'
    	FROM users U
    		INNER JOIN comment_likes CL ON U.id = CL.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 질문좋아요 횟수 (AL, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_daily_ask_likes AS
    	SELECT date_format(addtime(AL.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(AL.id) AS 'ask_like_count'
    	FROM users U
    		INNER JOIN ask_likes AL ON U.id = AL.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY date ORDER BY date DESC;
    """
    # 일자별 공유 횟수 (SL, 아르바이트)
    self.connection.execute """
    CREATE VIEW v_alba_daily_shares AS
    	SELECT date_format(addtime(SL.created_at, '09:00:00'), '%Y-%m-%d') AS date, count(SL.id) AS 'share_count'
    	FROM users U
    		INNER JOIN share_logs SL ON U.id = SL.user_id
    		WHERE U.user_role = 'alba'
    	GROUP BY date ORDER BY date DESC;
    """

  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS v_user_visits;"
    self.connection.execute "DROP VIEW IF EXISTS v_user_votes;"
    self.connection.execute "DROP VIEW IF EXISTS v_user_comments;"
    self.connection.execute "DROP VIEW IF EXISTS v_user_asks;"
    self.connection.execute "DROP VIEW IF EXISTS v_user_comment_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_user_ask_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_user_shares;"

    self.connection.execute "DROP VIEW IF EXISTS v_daily_signups;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_visits;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_votes;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_comments;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_asks;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_comment_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_ask_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_shares;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_users;"
    self.connection.execute "DROP VIEW IF EXISTS v_daily_active;"

    self.connection.execute "DROP VIEW IF EXISTS v_weekly_signups;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_visits;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_votes;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_comments;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_asks;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_comment_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_ask_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_shares;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_users;"
    self.connection.execute "DROP VIEW IF EXISTS v_weekly_active;"

    self.connection.execute "DROP VIEW IF EXISTS v_monthly_signups;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_visits;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_votes;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_comments;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_asks;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_comment_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_ask_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_shares;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_users;"
    self.connection.execute "DROP VIEW IF EXISTS v_monthly_active;"

    self.connection.execute "DROP VIEW IF EXISTS v_ask_votes;"
    self.connection.execute "DROP VIEW IF EXISTS v_ask_comments;"
    self.connection.execute "DROP VIEW IF EXISTS v_ask_comments_others;"
    self.connection.execute "DROP VIEW IF EXISTS v_ask_comments_my;"
    self.connection.execute "DROP VIEW IF EXISTS v_ask_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_ask_shares;"

    self.connection.execute "DROP VIEW IF EXISTS v_alba_visits;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_votes;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_comments;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_asks;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_comment_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_ask_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_shares;"

    self.connection.execute "DROP VIEW IF EXISTS v_alba_daily_visits;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_daily_votes;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_daily_comments;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_daily_asks;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_daily_comment_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_daily_ask_likes;"
    self.connection.execute "DROP VIEW IF EXISTS v_alba_daily_shares;"
  end
end
