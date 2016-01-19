class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  skip_before_filter :auth_user
  
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
      params[:user][:remember_me] = true
      params[:user][:agree_access_term] = true
    end
    
    params[:user][:password_confirmation] = params[:user][:password]
    params[:user][:string_id] = User.get_uniq_string_id( params[:user][:email].split("@")[0] )
    super
  end
  
  def edit
  end
  
  def update
    unless params[:user][:gender].blank? 
      params[:user][:gender] = ActiveRecord::Type::Boolean.new.type_cast_from_database(params[:user][:gender])
    end
    super
  end
  
  # DELETE /users/delete_photo.json 
  def delete_photo
    SquarePreviewPhoto.where(:parent_type => "user", :parent_id => current_user.id).destroy_all
    current_user.photo.destroy
    current_user.save
    render :json => {:status => "success"}
  end
  
  
  protected
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
  
  def after_create_path_for(resource)
    path = root_path
    path
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