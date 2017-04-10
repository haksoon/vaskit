class Users::SessionsController < Devise::SessionsController
  # GET /users/sign_in
  def new
    respond_to do |format|
      format.html {}
      format.json do
        render json: {}
      end
    end
  end

  # POST /users/sign_in.json
  def create
    data = params[:data][:user]
    reg = /^[0-9a-zA-Z\-_.]+@[a-z0-9]+[.][a-z]{2,3}[.]?[a-z]{0,2}$/

    if data[:email].blank?
      render json: { status: 'blank_email' }
    elsif data[:password].blank?
      render json: { status: 'blank_password' }
    elsif !data[:email].match(reg)
      render json: { status: 'not_email' }
    elsif data[:password].length < 8
      render json: { status: 'not_enough_password' }
    else
      resource = User.find_for_database_authentication(email: data[:email])
      if resource.blank?
        render json: { status: 'not_exist' }
      elsif resource.valid_password?(data[:password])
        sign_in(resource_name, resource)
        resource.remember_me!
        user_visits
        auth_app_create(resource)
        render json: { status: 'success', string_id: resource.string_id }
      else
        render json: { status: 'invalid_password' }
      end
    end
  end

  # DELETE /users/sign_out.json
  def destroy
    sign_out_all_scopes
    auth_app_create(nil)
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: {} }
    end
  end

  # GET /users/alarm_check.json
  def alarm_check
    if current_user
      ask_tmp = !AskTmp.find_by(user_id: current_user.id).nil?
      alarms = Alarm.where(user_id: current_user.id)
                    .order(updated_at: :desc).limit(20)
      alarm_count = alarms.pluck(:is_read).count(false)
    end
    render json: { current_user: current_user, ask_tmp: ask_tmp, alarm_count: alarm_count }
  end

  # GET /users
  def users
  end

  # GET /users/get_user_profile.json
  def get_user_profile
    if current_user
      my_asks_in_progress_count = Ask.where(user_id: current_user.id, be_completed: false).count
      my_completed_asks_count = AskComplete.where(user_id: current_user.id).count
      my_likes_count = AskLike.where(user_id: current_user.id).count
      my_votes_count = Vote.where(user_id: current_user.id).count
      my_comments_count = Comment.where(user_id: current_user.id, is_deleted: false).count
    end
    render json: {
      current_user: current_user,
      my_asks_in_progress_count: my_asks_in_progress_count,
      my_completed_asks_count: my_completed_asks_count,
      my_likes_count: my_likes_count,
      my_votes_count: my_votes_count,
      my_comments_count: my_comments_count
    }
  end

  # GET /users/get_user_alarms.json
  def get_user_alarms
    if current_user
      alarms = Alarm.where(user_id: current_user.id)
                    .order(updated_at: :desc)
                    .limit(20)
      alarm_count = alarms.pluck(:is_read).count(false)
      alarms = alarms.as_json(include: [:user,
                                        :send_user,
                                        :ask_owner_user,
                                        :comment_owner_user,
                                        { ask: { include: [:left_ask_deal, :right_ask_deal] } },
                                        { comment: { include: [:user] } },
                                        { original_comment: { include: [:user] } }])
    end
    render json: { alarms: alarms, alarm_count: alarm_count }
  end

  # GET /users/get_my_recent_ask.json
  def get_my_recent_ask
    if current_user
      my_ask = Ask.where(user_id: current_user.id, be_completed: false)
                  .order(updated_at: :desc).first
                  .as_json(include: [:left_ask_deal, :right_ask_deal])
    end
    render json: { my_ask: my_ask }
  end

  # GET /users/history?type=___
  def history
    @type = params[:type]

    respond_to do |format|
      format.html {}
      format.json do
        asks = []
        if current_user
            case @type
            when 'my_asks_in_progress'
              asks = Ask.where(user_id: current_user.id, be_completed: false)
                        .order(updated_at: :desc)
                        .page(params[:page]).per(Ask::ASK_PER)
              is_more_load = asks.total_pages > params[:page].to_i
            when 'my_completed_asks'
              my_completed_asks = AskComplete.where(user_id: current_user.id)
                                             .order(id: :desc)
                                             .page(params[:page]).per(Ask::ASK_PER)
              is_more_load = my_completed_asks.total_pages > params[:page].to_i
              my_completed_asks = my_completed_asks.map(&:ask_id).uniq
              asks = Ask.where(id: my_completed_asks)
                        .order("FIELD(id,#{my_completed_asks.join(',')})") unless my_completed_asks.blank?
            when 'my_likes'
              my_likes = AskLike.where(user_id: current_user.id)
                                .order(id: :desc)
                                .page(params[:page]).per(Ask::ASK_PER)
              is_more_load = my_likes.total_pages > params[:page].to_i
              my_likes = my_likes.map(&:ask_id).uniq
              asks = Ask.where(id: my_likes)
                        .order("FIELD(id,#{my_likes.join(',')})") unless my_likes.blank?
            when 'my_votes'
              my_votes = Vote.where(user_id: current_user.id)
                             .order(id: :desc)
                             .page(params[:page]).per(Ask::ASK_PER)
              is_more_load = my_votes.total_pages > params[:page].to_i
              my_votes = my_votes.map(&:ask_id).uniq
              asks = Ask.where(id: my_votes)
                        .order("FIELD(id,#{my_votes.join(',')})") unless my_votes.blank?
            when 'my_comments'
              # 다른 타입은 ask와 1:1 관계이기 때문에 문제 없으나 댓글의 경우 1:다 관계이므로 연속으로 중복된 댓글의 경우 ask 갯수가 ASK_PER에 미달할 가능성이 있어 page/per를 ASK에 적용함
              my_comments = Comment.where(user_id: current_user.id, is_deleted: false)
                                   .order(id: :desc).map(&:ask_id).uniq
              asks = Ask.where(id: my_comments)
                        .order("FIELD(id,#{my_comments.join(',')})")
                        .page(params[:page]).per(Ask::ASK_PER) unless my_comments.blank?
              is_more_load = asks.total_pages > params[:page].to_i
            end

            asks = asks.as_json(include: [{ user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } },
                                          { left_ask_deal: { include: [{ recent_comment: { include: [user: { only: [:id, :string_id] }] } } ] } },
                                          { right_ask_deal: { include: [{ recent_comment: { include: [user: { only: [:id, :string_id] }] } } ] } },
                                          :votes,
                                          { ask_likes: { include: { user: { only: [:id, :string_id] } } } },
                                          :ask_complete,
                                          :event]) unless asks.nil?
        end
        render json: { asks: asks, is_more_load: is_more_load }
      end
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
    new_string_id = params[:string_id]
    if User.find_by_string_id(new_string_id)
      status = 'fail'
    else
      status = 'success'
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
    if data[:sign_up_type] == 'facebook'
      data[:current_password] = 'is_facebook'
      data[:sign_up_type] = 'both'
    end

    if data[:current_password].blank?
      render json: { status: 'blank_current_password' }
    elsif data[:new_password].blank?
      render json: { status: 'blank_new_password' }
    elsif data[:new_password].length < 8
      render json: { status: 'not_enough_password' }
    elsif data[:new_password] != data[:new_password_confirmation]
      render json: { status: 'password_confirm_error' }
    elsif current_user.valid_password?(data[:current_password])
      resource = current_user
      resource.update_with_password(current_password: data[:current_password],
                                    password: data[:new_password],
                                    password_confirmation: data[:new_password_confirmation],
                                    sign_up_type: data[:sign_up_type])
      if resource.persisted?
        bypass_sign_in resource
        render json: { status: 'success' }
      end
    else
      render json: { status: 'invalid_password' }
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
    if User.where(id: current_user.id).pluck(params[:alarm_option])[0] == true
      message = 'off'
      current_user.update(params[:alarm_option] => false)
    else
      message = 'on'
      current_user.update(params[:alarm_option] => true)
    end
    render json: { message: message, current_user: current_user }
  end
end
