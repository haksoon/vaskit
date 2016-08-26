# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController
  skip_before_filter :auth_user
  after_action :set_gcm_key, :only => ["create"]

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
      @send_users = []
      @ask_owner_users = []
      @comment_owner_users = []
      @alrams.each do |alram|
        alram.is_read == false ? alram_count = alram_count + 1 : alram_count = alram_count
        send_user = alram.send_user_id != nil ? User.find_by_id(alram.send_user_id).string_id : ""
        ask_owner_user = alram.ask_owner_user_id != nil ? User.find_by_id(alram.ask_owner_user_id).string_id : ""
        comment_owner_user = alram.comment_owner_user_id != nil ? User.find_by_id(alram.comment_owner_user_id).string_id : ""
        @send_users << send_user
        @ask_owner_users << ask_owner_user
        @comment_owner_users << comment_owner_user
      end
    end
    render :json => {:current_user_string_id => current_user_string_id, :my_ask_count => my_ask_count, :my_vote_count => my_vote_count, :my_comment_count => my_comment_count, :in_progress_count => in_progress_count,
      :my_like_ask_count => my_like_ask_count, :alram_count => alram_count,
      :alrams => @alrams, :send_users => @send_users, :ask_owner_users => @ask_owner_users, :comment_owner_users => @comment_owner_users}
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

  def destroy
    # GCM Key 삭제
    unless cookies["gcm_key"] == nil
      gcm_key = cookies["gcm_key"]
      user_gcm_key = UserGcmKey.find_by(:gcm_key => gcm_key)
      if user_gcm_key
        user_gcm_key.delete
      end
    end

    # 기존 Devise 메소드
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
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

  def toggle_alram_option
    message = "on"
    if User.where(:id => current_user.id).pluck(params[:alram_option])[0] == true
      current_user.update(params[:alram_option] => false)
      message = "off"
    else
      current_user.update(params[:alram_option] => true)
    end
    render :json => {:message => message}
  end

end
