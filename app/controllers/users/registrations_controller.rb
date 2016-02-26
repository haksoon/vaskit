class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  skip_before_filter :auth_user
  before_filter :auth_admin, :only => ["destroy"]
  
  
  def new
    build_resource({:email => params[:email], :name => params[:name], :facebook_id => params[:facebook_id], :gender => params[:gender], :birthday => params[:birthday] })
    respond_with self.resource
  end
  
  def create
    if params[:user][:facebook_id].blank?
      params[:user][:sign_up_type] = "email"
    else
      params[:user][:password] = "is_facebook"
      params[:user][:sign_up_type] = "facebook"
      params[:user][:agree_access_term] = true
    end
    params[:user][:remember_me] = true
    
    params[:user][:password_confirmation] = params[:user][:password]
    params[:user][:string_id] = User.get_uniq_string_id( params[:user][:email].split("@")[0] )
    super
  end
  
  def edit
  end
  
  def update
    if current_user.sign_up_type == "facebook"
      params[:user][:current_password] = "is_facebook"
      params[:user][:sign_up_type] = "both"
    end
    if current_user.valid_password?(params[:user][:current_password])
      flash[:custom_notice] = "기존 비밀번호를 잘못 입력하였습니다"
    elsif params[:user][:password] != params[:user][:password_confirmation]
      flash[:custom_notice] = "신규 비밀번호와 비밀번호 확인란이 일치하지 않습니다"
    elsif params[:user][:password].length < 8
      flash[:custom_notice] = "비밀번호는 8자 이상으로 해주세요"
    else
      flash[:custom_notice] = "비밀번호 변경 성공"
    end
    super
  end
  
  def destroy
    user = User.find_by_id(params[:id])
    user.delete
    redirect_to(:back)
  end
  
  
  protected
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
  
  def after_create_path_for(resource)
    path = root_path
    path
  end
  
  def after_update_path_for(resource)
    "/users/manage"
  end
  
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation, :remember_me, :sign_up_type, :string_id, :name, :gender, :birthday, :facebook_id, :agree_access_term)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:email, :password, :password_confirmation, :remember_me, :sign_up_type, :string_id, :name, :gender, :birthday, :facebook_id, :agree_access_term)
    end
  end
end