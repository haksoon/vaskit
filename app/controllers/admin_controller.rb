# coding : utf-8
class AdminController < ApplicationController
  before_filter :auth_admin

  def index
    @notices = Notice.all.order("id desc")
    category_id = params[:category_id]
    if category_id
      @rank_asks = RankAsk.where(:category_id => category_id).order("ranking asc")
      if @rank_asks.blank?
        @asks = Ask.where(:category_id => category_id).order("id desc")
      else
        @asks = Ask.where(:category_id => category_id).where("id not in (?)", @rank_asks.map(&:ask_id)).order("id desc")
      end
      @category = Category.find(category_id)
    else
      @rank_asks = RankAsk.where(:category_id => nil).order("ranking asc")
      if @rank_asks.blank?
        @asks = Ask.all.order("id desc")
      else
        @asks = Ask.where("id not in (?)", @rank_asks.map(&:ask_id)).order("id desc")
      end
    end
    @categories = Category.all
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    render :layout => "layout_admin"
  end


  def table
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    tableModel = params[:table_name].classify.constantize
    @record_names = tableModel.columns.map(&:name)
    @records = tableModel.all.order("id desc")
    render :layout => "layout_admin"
  end

  def submit_rank_ask
    ask_id = params[:ask_id]
    ranking = params[:ranking]
    category_id = params[:category_id]
    category_id = nil if category_id.blank?
    rank_ask = RankAsk.where(:ranking => ranking, :category_id => category_id).first
    if rank_ask
      rank_ask.update(:ask_id => ask_id)
    else
      RankAsk.create(:ask_id => ask_id, :ranking => ranking, :category_id => category_id)
    end
    render :json => {:status => "success"}
  end

  def delete_rank_ask
    RankAsk.find(params[:rank_ask_id]).delete
    render :json => {:status => "success"}
  end

  def create_notice
    notice = Notice.create(:title => params[:title], :message => params[:message])
    User.where(:receive_notice_email => true).each do |user|
      UserMailer.send_notice(user, notice).deliver_now
    end
    render :json => {:status => "success"}
  end

  def analysis
    user_summaries = User.joins("LEFT JOIN v_user_visits UV ON `users`.id = UV.user_id").joins("LEFT JOIN v_user_votes V ON `users`.id = V.user_id LEFT JOIN v_user_comments C ON `users`.id = C.user_id LEFT JOIN v_user_asks A ON `users`.id = A.user_id LEFT JOIN v_user_comment_likes CL ON `users`.id = CL.user_id LEFT JOIN v_user_ask_likes AL ON `users`.id = AL.user_id LEFT JOIN v_user_shares SL ON `users`.id = SL.user_id").where(:user_role => "user").select("`users`.id AS 'user_id', `users`.email, `users`.string_id, `users`.name, date_format(`users`.created_at, '%Y-%m-%d') AS 'created_at', IFNULL(UV.visit_count, 0) AS 'visit_count', IFNULL(V.vote_count, 0) AS 'vote_count', IFNULL(C.comment_count, 0) AS 'comment_count', IFNULL(A.ask_count, 0) AS 'ask_count', IFNULL(CL.comment_like_count, 0) AS 'comment_like_count', IFNULL(AL.ask_like_count, 0) AS 'ask_like_count', IFNULL(SL.share_count, 0) AS 'share_count'").order("visit_count DESC")
    daily_summaries = UserVisit.joins("LEFT JOIN v_daily_signups SU ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = SU.date LEFT JOIN v_daily_active AU ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = AU.date LEFT JOIN v_daily_visits UV ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = UV.date LEFT JOIN v_daily_votes V ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = V.date LEFT JOIN v_daily_comments C ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = C.date LEFT JOIN v_daily_asks A ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = A.date LEFT JOIN v_daily_comment_likes CL ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = CL.date LEFT JOIN v_daily_ask_likes AL ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = AL.date LEFT JOIN v_daily_shares SL ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m-%d') = SL.date").select("date_format(`user_visits`.created_at, '%Y-%m-%d') AS date, IFNULL(SU.signup_count, 0) AS 'signup_count', IFNULL(AU.DAU, 0) AS 'DAU', IFNULL(UV.visit_count, 0) AS 'visit_count', IFNULL(V.vote_count, 0) AS 'vote_count', IFNULL(C.comment_count, 0) AS 'comment_count', IFNULL(A.ask_count, 0) AS 'ask_count', IFNULL(CL.comment_like_count, 0) AS 'comment_like_count', IFNULL(AL.ask_like_count, 0) AS 'ask_like_count', IFNULL(SL.share_count, 0) AS 'share_count'").group("date").order("date DESC")
    monthly_summaries = UserVisit.joins("LEFT JOIN v_monthly_signups SU ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = SU.month LEFT JOIN v_monthly_active AU ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = AU.month LEFT JOIN v_monthly_visits UV ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = UV.month LEFT JOIN v_monthly_votes V ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = V.month LEFT JOIN v_monthly_comments C ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = C.month LEFT JOIN v_monthly_asks A ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = A.month LEFT JOIN v_monthly_comment_likes CL ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = CL.month LEFT JOIN v_monthly_ask_likes AL ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = AL.month LEFT JOIN v_monthly_shares SL ON date_format(addtime(`user_visits`.created_at, '09:00:00'), '%Y-%m') = SL.month").select("date_format(`user_visits`.created_at, '%Y-%m') AS month, IFNULL(SU.signup_count, 0) AS 'signup_count', IFNULL(AU.MAU, 0) AS 'MAU', IFNULL(UV.visit_count, 0) AS 'visit_count', IFNULL(V.vote_count, 0) AS 'vote_count', IFNULL(C.comment_count, 0) AS 'comment_count', IFNULL(A.ask_count, 0) AS 'ask_count', IFNULL(CL.comment_like_count, 0) AS 'comment_like_count', IFNULL(AL.ask_like_count, 0) AS 'ask_like_count', IFNULL(SL.share_count, 0) AS 'share_count'").group("month").order("month DESC")
    @user_top_10 = user_summaries.limit(10)
    @daily_recent_10 = daily_summaries.limit(10)
    @monthly_recent_10 = monthly_summaries.limit(10)

    @total_visit_count = 0
    @total_vote_count = 0
    @total_comment_count = 0
    @total_ask_count = 0
    user_summaries.each do |u|
      @total_visit_count += u.visit_count
      @total_vote_count += u.vote_count
      @total_comment_count += u.comment_count
      @total_ask_count += u.ask_count
    end

    render :layout => "layout_admin"
  end

end
