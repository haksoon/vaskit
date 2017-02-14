class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  # GET /users/forgot_password
  def new
  end

  # POST /users/password.json
  def create
    resource_params = params[:data][:user]
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render json: { status: 'success' }
    else
      render json: { status: 'fail' }
    end
  end

  # GET /users/password/edit?reset_password_token=xxx
  # URL => /users/reset_password?reset_password_token=xxx
  def edit
  end

  # PUT /users/password.json
  def update
    data = params[:data][:user]

    if data[:password].length < 8
      render json: { status: 'not_enough_password' }
    elsif data[:password] != data[:password_confirmation]
      render json: { status: 'password_confirm_error' }
    else
      self.resource = resource_class.reset_password_by_token(data)
      if resource.sign_up_type == 'facebook'
        resource.update(sign_up_type: 'both')
      end
      yield resource if block_given?
      if resource.errors.empty?
        sign_in(resource_name, resource)
        render json: { status: 'success', string_id: resource.string_id }
      else
        render json: { status: 'fail' }
      end
    end
  end
end
