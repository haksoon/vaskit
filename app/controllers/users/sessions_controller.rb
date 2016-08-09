# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController
  skip_before_filter :auth_user

  #AJS추가
  def get_user_data
    if current_user
      current_user_string_id = User.find_by_id(current_user.id).string_id
      my_ask_count = Ask.where(:user_id => current_user.id).count
      my_vote_count = Vote.where(:user_id => current_user.id).count
      my_comment_count = Comment.where(:user_id => current_user.id).count
      in_progress_count = Ask.where(:user_id => current_user.id, :be_completed => false).count
      my_like_ask_count = AskLike.where(:user_id => current_user.id).count
      @alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(20)
      alram_count = 0
      @owner_users = []
      @send_users = []
      @alrams.each do |alram|
        alram.is_read == false ? alram_count = alram_count + 1 : alram_count = alram_count
        @owner_users << User.where(:id => alram.ask_owner_user_id).select(:string_id) # TODO: 중첩배열이 아닌 객체 배열로 보완 필요
        @send_users << User.where(:id => alram.send_user_id).select(:string_id) # TODO: 중첩배열이 아닌 객체 배열로 보완 필요
      end
    end
    render :json => {:current_user_string_id => current_user_string_id, :my_ask_count => my_ask_count, :my_vote_count => my_vote_count, :my_comment_count => my_comment_count, :in_progress_count => in_progress_count,
      :my_like_ask_count => my_like_ask_count, :alram_count => alram_count,
      :alrams => @alrams, :owner_users => @owner_users, :send_users => @send_users}
  end

  #AJS 추가
  def alram_check
    if current_user
      alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(20)
      alram_count = 0
      alrams.each do |alram|
        alram.is_read == false ? alram_count = alram_count + 1 : alram_count = alram_count
      end
    end
    render :json => {:alram_count => alram_count}
  end

  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource
      super
    else
      flash[:user_email] = params[:user][:email]
      flash[:custom_notice] = "입력하신 비밀번호가 틀립니다\\n다시 한 번 확인해 주세요"
      redirect_to "/users/sign_in"
    end
  end

  # def check_email
  #   is_new_email = true
  #   user = User.find_by_email(params[:email])
  #   is_new_email = false if user
  #   render :json => {:is_new_email => is_new_email}
  # end

  # def manage
  # end

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
