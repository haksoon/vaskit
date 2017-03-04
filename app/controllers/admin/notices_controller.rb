class Admin::NoticesController < Admin::HomeController

  # GET /admin/notices
  def index
    @notices = LogPushAdmin.page(params[:page]).per(10).order(id: :desc)
  end

  # GET /admin/notices/new
  def new
  end

  # GET /admin/notices/test
  def test
    return if params[:msg].blank? || params[:link].blank?
    params[:js] = '' if params[:js].nil? || params[:js] == 'false'
    payload = { msg: "#{params[:msg]}\n[테스트 푸쉬 by #{current_user.string_id}]",
                type: 'true',
                count: nil,
                id: 1,
                link: params[:link],
                js: params[:js] }
    registration_ids_ios = UserGcmKey.where(user_id: 1).where('device_id LIKE ?', 'ios%').pluck(:gcm_key)
    registration_ids_aos = UserGcmKey.where(user_id: 1).where('device_id LIKE ?', 'android%').pluck(:gcm_key)

    response_ios = push_send_IOS(registration_ids_ios, payload) unless registration_ids_ios.blank?
    response_aos = push_send_AOS(registration_ids_aos, payload) unless registration_ids_aos.blank?

    count = 0
    count += JSON.parse(response_ios[:body])['success'].to_i unless response_ios.nil?
    count += JSON.parse(response_aos[:body])['success'].to_i unless response_aos.nil?
    @string = "#{count}대의 기기에 테스트 알림을 전송하였습니다"
  end

  # POST /admin/notices
  def create
    if params[:type].blank? || params[:filter].blank? || params[:msg].blank? || params[:link].blank?
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      redirect_to new_admin_notice_path and return
    end

    push_type = params[:type]
    params[:js] = '' if params[:js].nil? || params[:js] == 'false'
    payload = { msg: params[:msg],
                type: 'true',
                count: nil,
                id: 1,
                link: params[:link],
                js: params[:js] }

    if params[:filter] == 'all'
      if Rails.env == 'development'
        admin_user_ids = User.where(user_role: 'admin').pluck(:id)
        registration_ids_ios = UserGcmKey.where(user_id: admin_user_ids).where('device_id LIKE ?', 'ios%').pluck(:gcm_key)
        registration_ids_aos = UserGcmKey.where(user_id: admin_user_ids).where('device_id LIKE ?', 'android%').pluck(:gcm_key)
      else
        registration_ids_ios = UserGcmKey.where('device_id LIKE ?', 'ios%').pluck(:gcm_key)
        registration_ids_aos = UserGcmKey.where('device_id LIKE ?', 'android%').pluck(:gcm_key)
      end
    elsif params[:filter] == 'filter'
      filter_users =
        if Rails.env == 'development'
          User.where(user_role: 'admin')
        else
          User.all
        end

      unless params[:filter_gender].nil?
        if params[:filter_gender].length == 1 && params[:filter_gender][0] == 'male'
          filter_users = filter_users.where(gender: true)
        elsif params[:filter_gender].length == 1 && params[:filter_gender][0] == 'female'
          filter_users = filter_users.where(gender: false)
        end
      end

      unless params[:filter_age].nil?
        if params[:filter_age].length > 0 && params[:filter_age].length < 7
          age_filter = []
          age_20 = Date.new(Time.now.year - 18, 1, 1)
          age_20_1_end = Date.new(Time.now.year - 22, 1, 1)
          age_20_2_end = Date.new(Time.now.year - 25, 1, 1)
          age_30 = Date.new(Time.now.year - 28, 1, 1)
          age_30_1_end = Date.new(Time.now.year - 32, 1, 1)
          age_30_2_end = Date.new(Time.now.year - 35, 1, 1)
          age_30_3_end = Date.new(Time.now.year - 38, 1, 1)
          params[:filter_age].each do |age|
            age_filter << "users.birthday < '#{age_20}' AND users.birthday > '#{age_20_1_end}'" if age == 'early_20'
            age_filter << "users.birthday < '#{age_20_1_end}' AND users.birthday > '#{age_20_2_end}'" if age == 'middle_20'
            age_filter << "users.birthday < '#{age_20_2_end}' AND users.birthday > '#{age_30}'" if age == 'latter_20'
            age_filter << "users.birthday < '#{age_30}' AND users.birthday > '#{age_30_1_end}'" if age == 'early_30'
            age_filter << "users.birthday < '#{age_30_1_end}' AND users.birthday > '#{age_30_2_end}'" if age == 'middle_30'
            age_filter << "users.birthday < '#{age_30_2_end}' AND users.birthday > '#{age_30_3_end}'" if age == 'latter_30'
            age_filter << "users.birthday IS NULL OR (users.birthday > '#{age_20}' OR users.birthday < '#{age_30_3_end}')" if age == 'etc'
          end
          filter_users = filter_users.where(age_filter.join(' OR '))
        end
      end

      ios_checked = true
      aos_checked = true
      if !params[:filter_device].nil? && params[:filter_device].length == 1
        ios_checked = false
        aos_checked = false
        params[:filter_device].each do |device|
          ios_checked = true if device == 'ios'
          aos_checked = true if device == 'aos'
        end
      end

      filter_user_ids = filter_users.pluck(:id)
      registration_ids_ios = UserGcmKey.where(user_id: filter_user_ids).where('device_id LIKE ?', 'ios%').pluck(:gcm_key) if ios_checked
      registration_ids_aos = UserGcmKey.where(user_id: filter_user_ids).where('device_id LIKE ?', 'android%').pluck(:gcm_key) if aos_checked
    elsif params[:filter] == 'specific'
      filter_user_ids = params[:filter_user_id]
      registration_ids_ios = UserGcmKey.where(user_id: filter_user_ids).where('device_id LIKE ?', 'ios%').pluck(:gcm_key)
      registration_ids_aos = UserGcmKey.where(user_id: filter_user_ids).where('device_id LIKE ?', 'android%').pluck(:gcm_key)
    end

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

    flash['success'] = "총 #{success_count}개의 푸시알림을 성공적으로 전송하였습니다"
    redirect_to admin_notices_path
  end
end
