# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController
  skip_before_filter :auth_user

  #AJS추가
  def show
    if current_user
      current_user_string_id = User.where(:id => current_user.id).select(:string_id)
      my_ask_count = Ask.where(:user_id => current_user.id).count
      my_vote_count = Vote.where(:user_id => current_user.id).count
      my_comment_count = Comment.where(:user_id => current_user.id).count
      in_progress_count = Ask.where(:user_id => current_user.id, :be_completed => false).count
      alram_count = Alram.where(:user_id => current_user.id, :is_read => false).count
      is_new_alram = Alram.where(:user_id => current_user.id, :is_read => false).blank?
      @alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(15)
      @owner_users = []
      @send_users = []
      @alrams.each do |alram|
        owner_user = User.where(:id => alram.ask_owner_user_id).select(:string_id)
        send_user = User.where(:id => alram.send_user_id).select(:string_id)
        @owner_users = owner_user
        @send_users = send_user
      end
    end
    render :json => {:current_user_string_id => current_user_string_id, :my_ask_count => my_ask_count, :my_vote_count => my_vote_count, :my_comment_count => my_comment_count, :in_progress_count => in_progress_count, :alram_count => alram_count,
      :is_new_alram => is_new_alram, :alrams => @alrams, :owner_users => @owner_users, :send_users => @send_users}
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
    new_string_id = params[:string_id] #AJS추가
    if User.find_by_string_id(new_string_id)
      status = "fail"
    else
      current_user.update(:string_id => new_string_id)
    end
    render :json => {:status => status, :new_string_id => new_string_id}
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
