# coding : utf-8
class Users::FacebookController < Devise::PasswordsController
  after_action :user_visits, only: [:auth]

  # POST /users/facebook.json
  def auth
    data = params[:data]

    facebook_id = data[:id]
    email = data[:email]
    name = data[:name]
    birthday = Date.strptime(data[:birthday], "%m/%d/%Y") unless data[:birthday] == nil
    gender = data[:gender] == "male" ? true : false unless data[:gender] == nil
    avatar = open(data[:picture][:data][:url]) unless data[:picture] == nil

    user = User.where(facebook_id: facebook_id).first
    user = User.where("email = ? AND facebook_id = ?", email, "").first if user.blank?

    if user.blank?
      if email && name && facebook_id && gender && birthday
        string_id = User.get_uniq_string_id( email.split("@")[0] )
        user = User.create(email: email, password: "is_facebook", password_confirmation: "is_facebook",
                           facebook_id: facebook_id, string_id: string_id, name: name,
                           birthday: birthday, gender: gender,
                           sign_up_type: "facebook", remember_me: true, avatar: avatar)
        sign_in user
        render json: {status: "success", string_id: user.string_id}
      else
        render json: {status: "not_enough", facebook_id: facebook_id, email: email, name: name, birthday: birthday, gender: gender, avatar: data[:picture][:data][:url]}
      end
    elsif user && user.sign_up_type == "email"
      if user.avatar.blank?
        user.update(facebook_id: facebook_id, sign_up_type: "both", remember_me: true, avatar: avatar)
      else
        user.update(facebook_id: facebook_id, sign_up_type: "both", remember_me: true)
      end
      sign_in user
      render json: {status: "success", string_id: user.string_id}
    else
      if user.avatar.blank?
        user.update(remember_me: true, avatar: avatar)
      else
        user.update(remember_me: true)
      end
      sign_in user
      render json: {status: "success", string_id: user.string_id}
    end
  end

end
