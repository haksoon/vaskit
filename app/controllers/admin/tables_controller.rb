class Admin::TablesController < Admin::HomeController
  # GET /admin/tables
  # GET /admin/tables/:table_name
  def index
    @tables = ActiveRecord::Base.connection.tables
    @tables -= %w(schema_migrations delayed_jobs
                v_alba_ask_likes v_alba_asks v_alba_comment_likes v_alba_comments v_alba_shares v_alba_visits v_alba_votes
                v_alba_daily_ask_likes v_alba_daily_asks v_alba_daily_comment_likes v_alba_daily_comments v_alba_daily_shares v_alba_daily_visits v_alba_daily_votes
                v_user_ask_likes v_user_asks v_user_comment_likes v_user_comments v_user_shares v_user_visits v_user_votes
                v_ask_comments v_ask_comments_my v_ask_comments_others v_ask_likes v_ask_shares v_ask_votes
                v_daily_active v_daily_ask_likes v_daily_asks v_daily_comment_likes v_daily_comments v_daily_shares v_daily_signups v_daily_users v_daily_visits v_daily_votes
                v_weekly_active v_weekly_ask_likes v_weekly_asks v_weekly_comment_likes v_weekly_comments v_weekly_shares v_weekly_signups v_weekly_users v_weekly_visits v_weekly_votes
                v_monthly_active v_monthly_ask_likes v_monthly_asks v_monthly_comment_likes v_monthly_comments v_monthly_shares v_monthly_signups v_monthly_users v_monthly_visits v_monthly_votes
                view_alba view_alba_daily view_ask_details view_asks view_daily view_monthly view_users view_weekly)

    if params[:table_name]
      @tableModel = params[:table_name].classify.constantize
      @records = @tableModel.page(params[:page]).per(50).order(id: :desc)
      @record_names = @tableModel.columns.map(&:name)
    end
  end
end
