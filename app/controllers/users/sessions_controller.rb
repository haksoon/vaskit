# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController
  skip_before_filter :auth_user

  #AJS추가
  def show
    if current_user
      current_user_id = User.where(:id => current_user.id).select(:string_id)
      my_ask_count = Ask.where(:user_id => current_user.id).count #AJS추가
      my_vote_count = Vote.where(:user_id => current_user.id).count #AJS추가
      my_comment_count = Comment.where(:user_id => current_user.id).count #AJS추가
      in_progress_count = Ask.where(:user_id => current_user.id, :be_completed => false).count #AJS추가
      alram_count = Alram.where(:user_id => current_user.id, :is_read => false).count #AJS추가
    end
    render :json => {:current_user_id => current_user_id, :my_ask_count => my_ask_count, :my_vote_count => my_vote_count, :my_comment_count => my_comment_count, :in_progress_count => in_progress_count, :alram_count => alram_count}
  end

  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource
      super
    else
      flash[:custom_notice] = "입력하신 이메일 또는 비밀번호가 틀립니다.\\n다시 한 번 확인해 주세요."
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
