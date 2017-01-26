class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  after_action :user_visits, only: [:create]

  # GET /users/sign_up
  def new
    respond_to do |format|
      format.html
      format.json {
        render json: {}
      }
    end
  end

  # POST /users/sign_up.json
  def create
    data = params[:data][:user]
    reg = /^[0-9a-zA-Z\-_.]+@[a-z0-9]+[.][a-z]{2,3}[.]?[a-z]{0,2}$/

    if data[:facebook_id].blank?
      data[:sign_up_type] = "email"
    else
      data[:sign_up_type] = "facebook"
      data[:password] = "is_facebook"
      data[:password_confirmation] = data[:password]
    end

    if data[:email].blank?
      render json: {status: "blank_email"}
    elsif data[:password].blank?
      render json: {status: "blank_password"}
    elsif !data[:email].match(reg)
      render json: {status: "not_email"}
    elsif !User.find_for_database_authentication(email: data[:email]).blank?
      render json: {status: "already_exist_email"}
    elsif data[:password].length < 8
      render json: {status: "not_enough_password"}
    elsif data[:password] != data[:password_confirmation]
      render json: {status: "password_confirm_error"}
    else
      if data["birthday(1i)"] == nil || data["birthday(2i)"] == nil || data["birthday(3i)"] == nil || data["birthday(1i)"] == "" || data["birthday(2i)"] == "" || data["birthday(3i)"] == ""
        render json: {status: "birthday_not_selected"}
      elsif data[:gender] == nil || data[:gender] == ""
        render json: {status: "gender_not_selected"}
      elsif data[:agree_access_term] != "1"
        render json: {status: "agree_access_term"}
      else
        data[:birthday] = Date.new(data["birthday(1i)"].to_i, data["birthday(2i)"].to_i, data["birthday(3i)"].to_i).strftime("%m/%d/%Y")

        data[:string_id] = User.get_uniq_string_id( data[:email].split("@")[0] )
        data[:remember_me] = true

        build_resource({
          email: data[:email],
          password: data[:password],
          birthday: data[:birthday],
          gender: data[:gender],
          string_id: data[:string_id],
          sign_up_type: data[:sign_up_type],
          facebook_id: data[:facebook_id],
          name: data[:name],
          remember_me: data[:remember_me],
          agree_access_term: data[:agree_access_term],
          avatar: data[:avatar]
        })

        resource.save
        if resource.persisted?
          sign_up(resource_name, resource)
          render json: {status: "success", string_id: data[:string_id]}

          user = User.find_by(email: data[:email])
          UserMailer.delay.welcome_email(user)
          AdminMailer.delay.signup_submitted(user)
        end
      end
    end
  end

  # POST /users/check_email.json
  def check_email
    is_new_email = true if User.find_by_email(params[:email]).blank?
    render json: {is_new_email: is_new_email}
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :email, :password, :password_confirmation, :remember_me, :sign_up_type, :string_id, :name, :gender, :birthday, :facebook_id, :agree_access_term, :avatar ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :current_password, :password, :password_confirmation, :sign_up_type ])
  end
end
