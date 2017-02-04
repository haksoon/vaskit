class Admin::AsksController < Admin::HomeController

  # GET /admin/asks
  def index
    @admin_users = User.where(user_role: "admin")
    @asks = Ask.where(be_completed: false)
              .page(params[:page]).per(10).order(id: :desc)
    @asks_count = Ask.where(be_completed: false).count / 10 + 1
    render layout: "layout_admin"
  end

  # POST /admin/asks.json
  def create
    admin_user_id = params[:admin_user_id]
    comment_ask_id = params[:comment_ask_id]
    comment_message = params[:comment_message]
    is_left = params[:is_left]

    ask = Ask.find(comment_ask_id)
    ask_deal_id = is_left == "true" ? ask.left_ask_deal_id : ask.right_ask_deal_id

    vote = Vote.find_by(ask_id: comment_ask_id, user_id: admin_user_id)
    if vote
      vote.update(ask_deal_id: ask_deal_id)
    else
      vote = Vote.create(ask_id: comment_ask_id, ask_deal_id: ask_deal_id, user_id: admin_user_id)
    end

    Comment.create(user_id: admin_user_id, ask_id: comment_ask_id, ask_deal_id: ask_deal_id, content: comment_message)
    render json: {status: 'ok'}
  end
end
