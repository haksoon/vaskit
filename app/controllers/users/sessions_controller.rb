# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController
  skip_before_filter :auth_user

  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource
      super
    else
      flash[:custom_notice] = "이메일/아이디 또는 비밀번호가 다릅니다.\\n다시한번 확인해 주세요."
      redirect_to "/users/sign_in"
    end
  end

  # def check_email
  #   is_new_email = true
  #   user = User.find_by_email(params[:email])
  #   is_new_email = false if user
  #   render :json => {:is_new_email => is_new_email}
  # end

  def manage

  end

  def change_nickname
    status = "success"
    if User.find_by_string_id(params[:string_id])
      status = "fail"
    else
      current_user.update(:string_id => params[:string_id])
    end

    render :json => {:status => status}
  end


  def toggle_receive_notice
    message = "receive"
    if current_user.receive_notice_email
      current_user.update(:receive_notice_email => false)
      message = "not_receive"
    else
      current_user.update(:receive_notice_email => true)
    end

    render :json => {:message => message}
  end

end
