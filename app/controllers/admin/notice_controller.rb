class Admin::NoticeController < Admin::HomeController

  # GET /admin/notice
  def index
    @notices = Notice.all.order("id desc")
    render :layout => "layout_admin"
  end

  # POST /admin/notice.json
  def create
    notice = Notice.create(:title => params[:title], :message => params[:message])
    User.where(:receive_notice_email => true).each do |user|
      UserMailer.delay.send_notice(user, notice)
    end
    render :json => {:status => "success"}
  end

  # POST /admin/notice/check_user_gcm.json
  def check_user_gcm
    device = UserGcmKey.where(user_id: params[:id].to_i).length
    render :json => {:device => device}
  end

  def notice_push_send
    payload = {
      msg: params[:msg],
      type: "true",
      count: nil,
      id: 1,
      link: params[:link],
      js: params[:js],
    }
    # js가 비어있으면 안됨
    if payload[:js] == nil || payload[:js] == "false"
      payload[:js] = ""
    end


    if params[:filter] == "all"
      push_send_to_all("notice", payload)
    else
      filter_user_ids = []
      aos_checked = true
      ios_checked = true

      if params[:filter] == "filter"
        aos_checked = false
        ios_checked = false
        age_20 = Date.new(Time.now.year - 18, 1, 1)
        age_20_1_end = Date.new(Time.now.year - 22, 1, 1)
        age_20_2_end = Date.new(Time.now.year - 25, 1, 1)
        age_30 = Date.new(Time.now.year - 28, 1, 1)
        age_30_1_end = Date.new(Time.now.year - 32, 1, 1)
        age_30_2_end = Date.new(Time.now.year - 35, 1, 1)
        age_30_3_end = Date.new(Time.now.year - 38, 1, 1)

        if params[:filter_data][:gender].length == 2
          filter_users = User.all
        elsif params[:filter_data][:gender].length == 1 && params[:filter_data][:gender][0] == "male"
          filter_users = User.where(:gender => true)
        elsif params[:filter_data][:gender].length == 1 && params[:filter_data][:gender][0] == "female"
          filter_users = User.where(:gender => false)
        end

        params[:filter_data][:age].each do |age|
          if age == "early_20"
            filter_user_ids << filter_users.where("users.birthday < ? AND users.birthday > ?", age_20, age_20_1_end).pluck(:id)
          elsif age == "middle_20"
            filter_user_ids << filter_users.where("users.birthday < ? AND users.birthday > ?", age_20_1_end, age_20_2_end).pluck(:id)
          elsif age == "latter_20"
            filter_user_ids << filter_users.where("users.birthday < ? AND users.birthday > ?", age_20_2_end, age_30).pluck(:id)
          elsif age == "early_30"
            filter_user_ids << filter_users.where("users.birthday < ? AND users.birthday > ?", age_30, age_30_1_end).pluck(:id)
          elsif age == "middle_30"
            filter_user_ids << filter_users.where("users.birthday < ? AND users.birthday > ?", age_30_1_end, age_30_2_end).pluck(:id)
          elsif age == "latter_30"
            filter_user_ids << filter_users.where("users.birthday < ? AND users.birthday > ?", age_30_2_end, age_30_3_end).pluck(:id)
          elsif age == "etc"
            filter_user_ids << filter_users.where("users.birthday IS NULL OR (users.birthday > ? OR users.birthday < ?)", age_20, age_30_3_end).pluck(:id)
          end
        end
        params[:filter_data][:device].each do |device|
          if device == "ios"
            ios_checked = true
          elsif device == "aos"
            aos_checked = true
          end
        end
      elsif params[:filter] == "specific"
        filter_user_ids = params[:filter_data][:user_ids]
      end

      if ios_checked
        registration_ids_ios = UserGcmKey.where(user_id: filter_user_ids).where("device_id LIKE ?", "ios%").pluck(:gcm_key)
      end
      if aos_checked
        registration_ids_aos = UserGcmKey.where(user_id: filter_user_ids).where("device_id LIKE ?", "android%").pluck(:gcm_key)
      end
      response_ios = push_send_IOS(registration_ids_ios, payload) unless registration_ids_ios.blank?
      response_aos = push_send_AOS(registration_ids_aos, payload) unless registration_ids_aos.blank?
    end

    render :json => {:status => "success"}
  end
end
