class Admin::HomeController < ActionController::Base
  include PushSend
  before_action :auth_admin
  skip_before_action :auth_admin, only: [:create, :destroy]
  layout 'admin'

  # GET /admin
  def index
    render template: '/admin/index'
  end

  # POST /admin/sign_in
  def create
    resource = User.find_for_database_authentication(email: params[:user][:email])
    if !resource.valid_password?(params[:user][:password])
      flash[:error] = '비밀번호를 확인해주세요'
    elsif resource.user_role != 'admin'
      flash[:error] = '어드민 계정이 아닙니다'
    else
      flash[:success] = '로그인하였습니다'
      sign_in(:user, resource)
      resource.remember_me!
    end
    redirect_to admin_path
  end

  # POST /admin/sign_out
  def destroy
    sign_out_all_scopes
    redirect_to admin_path
  end

  protected

  def auth_admin
    return if current_user && current_user.user_role == 'admin'
    render template: '/admin/not_auth'
  end
end
