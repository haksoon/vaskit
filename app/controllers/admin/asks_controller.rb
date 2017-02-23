class Admin::AsksController < Admin::HomeController
  before_action :set_ask, only: [:show, :update]
  before_action :load_admin_users, only: [:show, :update]

  # GET /admin/asks
  def index
    @asks = Ask.where(be_completed: false)
               .page(params[:page]).per(10).order(id: :desc)
  end

  # GET /admin/asks/:id
  def show
    @comment = Comment.new
  end

  # PATCH /admin/asks/:id
  def update
    params[:comment][:ask_id] = @ask.id

    @comment = Comment.new(comment_params)
    if @comment.save
      flash['success'] = '댓글을 성공적으로 작성하였습니다'
      vote = Vote.find_by(ask_id: @ask.id, user_id: params[:comment][:user_id])
      if vote.nil?
        flash['info'] = '아직 투표하지 않은 유저이므로 투표에 참여하였습니다'
        vote = Vote.create(ask_id: @ask.id, ask_deal_id: params[:comment][:ask_deal_id], user_id: params[:comment][:user_id])
      elsif vote && vote.ask_deal_id != params[:comment][:ask_deal_id].to_i
        flash['warning'] = '이미 반대 방향에 투표한 유저이므로 투표를 수정하였습니다'
        vote.update(ask_deal_id: params[:comment][:ask_deal_id])
      end
      redirect_to admin_ask_path(@ask.id)
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :show
    end
  end

  private

  def set_ask
    @ask = Ask.find(params[:id])
  end

  def load_admin_users
    @admin_users = User.where(user_role: 'admin')
                       .order(birthday: :desc)
  end

  def comment_params
    params.require(:comment).permit(:user_id,
                                    :content,
                                    :ask_id,
                                    :ask_deal_id,
                                    :comment_id,
                                    :image)
  end
end
