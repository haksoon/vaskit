# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController

  # GET /users/sign_in
  def new
    respond_to do |format|
      format.html {}
      format.json {
        render json: {}
      }
    end
  end

  # POST /users/sign_in.json
  def create
    data = params[:data][:user]
    reg = /^[0-9a-zA-Z\-_.]+@[a-z0-9]+[.][a-z]{2,3}[.]?[a-z]{0,2}$/

    if data[:email].blank?
      render json: { status: "blank_email" }
    elsif data[:password].blank?
      render json: { status: "blank_password" }
    elsif !data[:email].match(reg)
      render json: { status: "not_email" }
    elsif data[:password].length < 8
      render json: { status: "not_enough_password" }
    else
      resource = User.find_for_database_authentication(email: data[:email])
      if resource.blank?
        render json: { status: "not_exist" }
      elsif resource.valid_password?(data[:password])
        sign_in(resource_name, resource)
        resource.remember_me!
        user_visits
        render json: { status: "success", string_id: resource.string_id }
      else
        render json: { status: "invalid_password" }
      end
    end
  end

  # DELETE /users/sign_out.json
  def destroy
    sign_out_all_scopes
    render json: {}
  end



  # GET /users/alarm_check.json
  def alarm_check
    if current_user
      alarms = Alarm.where(user_id: current_user.id).order(updated_at: :desc).limit(20)
      alarm_count = alarms.pluck(:is_read).count(false)
    end
    render json: { current_user: current_user, alarm_count: alarm_count }
  end



  # GET /users
  def users
  end

  # GET /users/get_user_profile.json
  def get_user_profile
    if current_user
      my_asks_in_progress_count = Ask.where(user_id: current_user.id, be_completed: false).count
      my_asks_count = Ask.where(user_id: current_user.id).count
      my_likes_count = AskLike.where(user_id: current_user.id).count
      my_votes_count = Vote.where(user_id: current_user.id).count
      my_comments_count = Comment.where(user_id: current_user.id).count
    end
    render json: {
      current_user: current_user,
      my_asks_in_progress_count: my_asks_in_progress_count,
      my_asks_count: my_asks_count,
      my_likes_count: my_likes_count,
      my_votes_count: my_votes_count,
      my_comments_count: my_comments_count
    }
  end

  # GET /users/get_user_alarms.json
  def get_user_alarms
    if current_user
      alarms = Alarm.where(user_id: current_user.id).order(updated_at: :desc).limit(20)
      alarm_count = alarms.pluck(:is_read).count(false)
      alarms = alarms.as_json(include: [:user, :send_user, :ask_owner_user, :comment_owner_user, {ask: {include: [:left_ask_deal, :right_ask_deal]}}])
    end
    render json: { alarms: alarms, alarm_count: alarm_count }
  end

  # GET /users/get_my_asks.json
  def get_my_asks
    if current_user
      my_ask = Ask.where(user_id: current_user.id, be_completed: false).order(id: :desc).limit(1)
      # my_ask_detail = Views::DetailVoteCount.average_vote_count(my_ask[0].id) unless my_ask.blank?
      my_ask = my_ask.as_json(include: [:left_ask_deal, :right_ask_deal])
      # my_asks = Ask.where(user_id: current_user.id, be_completed: false).order(id: :desc)
      # my_asks_detail = []
      # my_asks.each do |my|
      #   # my_asks_detail << my.detail_vote_count
      #   my_asks_detail << Views::DetailVoteCount.average_vote_count(my.id)
      # end
      # my_asks = my_asks.as_json(include: [:left_ask_deal, :right_ask_deal, :ask_likes, :votes])
      # render json: { my_asks: my_asks, my_asks_detail: my_asks_detail }
    end
    render json: { my_ask: my_ask }
  end


  # GET /users/history?type=___
  def history
    @type = params[:type]
    if current_user
      @my_votes = Vote.where(user_id: current_user.id)
      @my_likes = AskLike.where(user_id: current_user.id)
      case @type
          when "my_asks_in_progress"
            @asks = Ask.where(user_id: current_user.id, be_completed: false)
                       .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                       .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
          when "my_asks"
            @asks = Ask.where(user_id: current_user.id)
                       .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                       .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
          when "my_likes"
            @asks = Ask.where(id: @my_likes.map(&:ask_id).uniq)
                       .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                       .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
          when "my_votes"
            @asks = Ask.where(id: @my_votes.map(&:ask_id).uniq)
                       .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                       .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
          when "my_comments"
            @asks = Ask.where(id: Comment.where(user_id: current_user.id).map(&:ask_id).uniq)
                       .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                       .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
      end
    else
      @asks = []
      @my_votes = []
      @my_likes = []
    end

    respond_to do |format|
      format.html {}
      format.json {
        render json: { asks: @asks }
      }
    end
  end

  # GET /users/settings
  def settings
  end

  # GET /users/settings/edit_profile
  def edit_profile
  end

  # DELETE /users/destroy_user_picture.json
  def destroy_user_picture
    User.find(current_user.id).update(avatar: nil)
    render json: {}
  end

  # PUT /users/change_nickname.json
  def change_nickname
    status = "success"
    new_string_id = params[:string_id] #AJS추가
    if User.find_by_string_id(new_string_id)
      status = "fail"
    else
      current_user.update(string_id: new_string_id)
    end
    render json: { status: status, new_string_id: new_string_id }
  end

  # GET /users/settings/edit_password
  def edit_password
  end

  # PUT /users/change_password.json
  def update_password
    data = params[:data][:user]

    data[:sign_up_type] = current_user.sign_up_type
    if data[:sign_up_type] == "facebook"
      data[:current_password] = "is_facebook"
      data[:sign_up_type] = "both"
    end

    if data[:current_password].blank?
      render json: { status: "blank_current_password" }
    elsif data[:new_password].blank?
      render json: { status: "blank_new_password" }
    elsif data[:new_password].length < 8
      render json: { status: "not_enough_password" }
    elsif data[:new_password] != data[:new_password_confirmation]
      render json: { status: "password_confirm_error" }
    elsif current_user.valid_password?(data[:current_password])
      resource = current_user
      resource.update_with_password({
        current_password: data[:current_password],
        password: data[:new_password],
        password_confirmation: data[:new_password_confirmation],
        sign_up_type: data[:sign_up_type]
      })
      if resource.persisted?
        bypass_sign_in resource
        render json: { status: "success" }
      end
    else
      render json: { status: "invalid_password" }
    end
  end

  # GET /users/settings/edit_push_alarm
  def edit_push_alarm
  end

  # GET /users/settings/edit_email_alarm
  def edit_email_alarm
  end

  # PUT /users/toggle_alarm_option.json
  def toggle_alarm_option
    message = "on"
    if User.where(id: current_user.id).pluck(params[:alarm_option])[0] == true
      current_user.update(params[:alarm_option] => false)
      message = "off"
    else
      current_user.update(params[:alarm_option] => true)
    end
    render json: { message: message, current_user: current_user }
  end

end
