class Admin::NoticeController < Admin::HomeController
  # GET /admin/notice
  def index
    @notices = Notice.all.order(id: :desc)
    render layout: 'layout_admin'
  end

  # POST /admin/notice.json
  def create
    notice = Notice.create(title: params[:title], message: params[:message])
    User.where(receive_notice_email: true).each do |user|
      UserMailer.delay.send_notice(user, notice)
    end
    render json: { status: 'success' }
  end

  # POST /admin/notice/check_user_gcm.json
  def check_user_gcm
    device = UserGcmKey.where(user_id: params[:id].to_i).length
    render json: { device: device }
  end

  def notice_push_send
    push_type = 'notice'
    payload = {
      msg: params[:msg],
      type: 'true',
      count: nil,
      id: 1,
      link: params[:link],
      js: params[:js]
    }

    # js가 비어있으면 안됨
    payload[:js] = '' if payload[:js].nil? || payload[:js] == 'false'

    if params[:filter] == 'all'
      push_send_to_all(push_type, payload)
    else
      ios_checked = true
      aos_checked = true
      if params[:filter] == 'filter'
        filter_users =
          if Rails.env == 'development'
            User.where(user_role: 'admin')
          else
            User.all
          end

        if params[:filter_data][:gender].length == 1 && params[:filter_data][:gender][0] == 'male'
          filter_users = filter_users.where(gender: true)
        elsif params[:filter_data][:gender].length == 1 && params[:filter_data][:gender][0] == 'female'
          filter_users = filter_users.where(gender: false)
        end

        age_filter = []
        age_20 = Date.new(Time.now.year - 18, 1, 1)
        age_20_1_end = Date.new(Time.now.year - 22, 1, 1)
        age_20_2_end = Date.new(Time.now.year - 25, 1, 1)
        age_30 = Date.new(Time.now.year - 28, 1, 1)
        age_30_1_end = Date.new(Time.now.year - 32, 1, 1)
        age_30_2_end = Date.new(Time.now.year - 35, 1, 1)
        age_30_3_end = Date.new(Time.now.year - 38, 1, 1)
        params[:filter_data][:age].each do |age|
          age_filter << "users.birthday < '#{age_20}' AND users.birthday > '#{age_20_1_end}'" if age == 'early_20'
          age_filter << "users.birthday < '#{age_20_1_end}' AND users.birthday > '#{age_20_2_end}'" if age == 'middle_20'
          age_filter << "users.birthday < '#{age_20_2_end}' AND users.birthday > '#{age_30}'" if age == 'latter_20'
          age_filter << "users.birthday < '#{age_30}' AND users.birthday > '#{age_30_1_end}'" if age == 'early_30'
          age_filter << "users.birthday < '#{age_30_1_end}' AND users.birthday > '#{age_30_2_end}'" if age == 'middle_30'
          age_filter << "users.birthday < '#{age_30_2_end}' AND users.birthday > '#{age_30_3_end}'" if age == 'latter_30'
          age_filter << "users.birthday IS NULL OR (users.birthday > '#{age_20}' OR users.birthday < '#{age_30_3_end}')" if age == 'etc'
        end
        filter_users = filter_users.where(age_filter.join(' OR '))

        ios_checked = false
        aos_checked = false
        params[:filter_data][:device].each do |device|
          ios_checked = true if device == 'ios'
          aos_checked = true if device == 'aos'
        end

        filter_user_ids = filter_users.pluck(:id)
      elsif params[:filter] == 'specific'
        filter_user_ids = params[:filter_data][:user_ids]
      end

      registration_ids_ios = UserGcmKey.where(user_id: filter_user_ids).where('device_id LIKE ?', 'ios%').pluck(:gcm_key) if ios_checked
      registration_ids_aos = UserGcmKey.where(user_id: filter_user_ids).where('device_id LIKE ?', 'android%').pluck(:gcm_key) if aos_checked

      response_ios = push_send_IOS(registration_ids_ios, payload) unless registration_ids_ios.blank?
      response_aos = push_send_AOS(registration_ids_aos, payload) unless registration_ids_aos.blank?

      ios_count = 0
      aos_count = 0
      success_count = 0
      failure_count = 0

      unless response_ios.nil?
        body_ios = JSON.parse(response_ios[:body])
        success_count += body_ios['success'].to_i
        failure_count += body_ios['failure'].to_i
        ios_count = registration_ids_ios.length.to_i
      end

      unless response_aos.nil?
        body_aos = JSON.parse(response_aos[:body])
        success_count += body_aos['success'].to_i
        failure_count += body_aos['failure'].to_i
        aos_count = registration_ids_aos.length.to_i
      end

      total_count = ios_count + aos_count

      LogPushAdmin.create(
        push_type: push_type,
        total_count: total_count,
        ios_count: ios_count,
        aos_count: aos_count,
        success_count: success_count,
        failure_count: failure_count,
        message: payload[:msg]
      )
    end

    render json: {}
  end
end
