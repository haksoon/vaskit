class Users::FacebookController < Devise::PasswordsController
  # POST /users/facebook.json
  def auth
    data = params[:data]

    facebook_id = data[:id]
    email = data[:email]
    name = data[:name]
    gender = data[:gender] == 'male' ? true : false unless data[:gender].nil?
    birthday = Date.strptime(data[:birthday], '%m/%d/%Y') unless data[:birthday].nil?
    avatar = open(data[:picture][:data][:url]) unless data[:picture].nil?

    user = User.where(facebook_id: facebook_id).first
    user = User.where(email: email, facebook_id: '').first if user.blank?

    if user.blank?
      if !email.nil? && !name.nil? && !facebook_id.nil? && !gender.nil? && !birthday.nil?
        string_id = User.get_uniq_string_id(email.split('@')[0])
        user = User.create(email: email,
                           password: 'is_facebook',
                           sign_up_type: 'facebook',
                           string_id: string_id,
                           name: name,
                           gender: gender,
                           birthday: birthday,
                           facebook_id: facebook_id,
                           agree_access_term: true,
                           remember_me: true,
                           avatar: avatar)
        sign_in user
        user_visits
        UserMailer.delay.welcome_email(user)
        render json: { status: 'success', string_id: user.string_id }
      else
        render json: { status: 'not_enough',
                       facebook_id: facebook_id,
                       email: email,
                       name: name,
                       birthday: birthday,
                       gender: gender,
                       avatar: data[:picture][:data][:url] }
      end
    elsif user && user.sign_up_type == 'email'
      if user.avatar.blank?
        user.update(facebook_id: facebook_id,
                    sign_up_type: 'both',
                    remember_me: true,
                    avatar: avatar)
      else
        user.update(facebook_id: facebook_id,
                    sign_up_type: 'both',
                    remember_me: true)
      end
      sign_in user
      user_visits
      render json: { status: 'success', string_id: user.string_id }
    else
      if user.avatar.blank?
        user.update(remember_me: true, avatar: avatar)
      else
        user.update(remember_me: true)
      end
      sign_in user
      user_visits
      render json: { status: 'success', string_id: user.string_id }
    end
    auth_app_create(nil)
  end
end
