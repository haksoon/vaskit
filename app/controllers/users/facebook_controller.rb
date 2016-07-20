# coding : utf-8
class Users::FacebookController < Devise::PasswordsController
  skip_before_filter :auth_user
  def auth
    if params["error"] == "access_denied"
      redirect_to root_path
    else
      url_string = "https://graph.facebook.com/v2.5/oauth/access_token?client_id=#{Facebook::CONFIG["app_id"]}&redirect_uri=#{CONFIG["host"]}/users/facebook&client_secret=#{Facebook::CONFIG["secret_key"]}&code=#{params[:code]}"
      uri = URI(url_string)
      response = JSON.parse(Net::HTTP.get(uri))
      access_token = response["access_token"]
      graph = Koala::Facebook::API.new(access_token) #이미지 저장해야됨.
      graph_user = graph.get_object("me?fields=email,name,gender,birthday", {:locale => "ko_KR"}, :api_version => "v2.5")
      email = graph_user["email"]
      name = graph_user["name"]
      facebook_id = graph_user["id"]
      gender = nil
      unless graph_user["gender"].blank?
        if graph_user["gender"] == "남성"
          gender = true
        else
          gender = false
        end
      end
      birthday = nil
      birthday = Date.strptime(graph_user["birthday"], "%m/%d/%Y") unless graph_user["birthday"].blank?

      testing = User.where(:id => graph)
      testing2 = User.where(:id => graph_user)
      user = User.where(:facebook_id => facebook_id).first
      user = User.where("email = ? AND facebook_id = ''", email).first if user.blank?
      if user.blank?
        if email && name && facebook_id && gender && birthday
          string_id = User.get_uniq_string_id( email.split("@")[0] )
          user = User.create(:email => email, :password => "is_facebook", :password_confirmation => "is_facebook", :sign_up_type => "facebook", :facebook_id => graph_user["id"], :name => name, :birthday => birthday, :gender => gender, :string_id => string_id, :remember_me => true)
          sign_in user
          redirect_to root_path
        else
          redirect_to new_user_registration_path(:email => email, :name => name, :facebook_id => facebook_id, :gender => gender, :birthday => birthday)
        end
      elsif user && user.sign_up_type == "email"
        user.update(:facebook_id => facebook_id, :sign_up_type => "both", :remember_me => true)
        sign_in user
        redirect_to root_path
      else
        user.remember_me = true
        sign_in user
        redirect_to root_path
      end
    end
  end

end
