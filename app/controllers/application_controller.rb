class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_filter :detect_browser, :set_visitor, :prepare_exception_notifier

  MOBILE_BROWSERS = ["android", "iphone", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]
  include PushSend

  def auth_user
    render :template => "/landing" unless current_user
  end

  def auth_admin
    render  :template => "/admin/not_auth" unless current_user && current_user.user_role == "admin"
  end

  def set_visitor
    @uniq_key = cookies["uniq_key"]
    @visitor = Visitor.find_by_uniq_key( Digest::MD5.hexdigest(@uniq_key ) ) unless @uniq_key.blank?
    if @visitor.blank?
      @uniq_key = Time.now.to_f.to_s + rand(1000000).to_s if @uniq_key.blank?
      hash_uniq_key = Digest::MD5.hexdigest(@uniq_key)
      @visitor = Visitor.create(:uniq_key => hash_uniq_key, :remote_ip => get_remote_ip)
    end
  end

  def detect_browser
    if params[:view]
      if params[:view] == 'mobile'
        session[:view] = 'mobile'
        session[:browser] = nil
      elsif params[:view] == 'standard'
        session[:view] = 'standard'
        session[:browser] = nil
      end
      session[:view_force] = true
    else
      unless session[:view_force]
        if request.headers["HTTP_USER_AGENT"]
          agent = request.headers["HTTP_USER_AGENT"].downcase

          session[:view] = nil
          MOBILE_BROWSERS.each do |m|
            if agent.match(m)
              session[:view] = 'mobile'
              session[:browser] = m
            break
            end
          end

          #아이폰 모바일 앱 검출
          if session[:browser] == 'iphone'
            if ( request.headers["HTTP_USER_AGENT"].include?('vaskit_iphone') == false && !request.headers["MyUserAgent"] )
              session[:browser] = 'iphone-web'
            end
          end

          #안드로이드 모바일웹 검출
          if session[:browser] == 'android'
            if ( request.headers["HTTP_USER_AGENT"].include?('VaskitAndroid') == false )
              session[:browser] = 'android-web'
            end
          end

          if agent.match('ipad')
            session[:view] = 'mobile'
            session[:browser] = 'iphone-web'
          end

          # ipad 검출
          # if agent.match('ipad')
            # session[:view] = 'mobile'
            # session[:browser] = 'ipad'
          # end
        end
        unless session[:view]
          session[:view] = 'standard'
          session[:browser] = nil
        end
      end
    end
  end

  def get_remote_ip
    ret = nil
    if request.env["HTTP_X_FORWARDED_FOR"] != nil
      ret = request.env["HTTP_X_FORWARDED_FOR"]
    else
      ret = request.env["REMOTE_ADDR"]
    end
    ret.split(",")[0]
  end

  def set_gcm_key
    gcm_key = cookies["gcm_key"]
    device_id = cookies["device_id"]
    app_ver = cookies["app_ver"]
    if gcm_key != nil && device_id != nil
      user_gcm_key = UserGcmKey.find_by(:gcm_key => gcm_key)
      if current_user
        if user_gcm_key
          user_gcm_key.update(:user_id => current_user.id, :device_id => device_id, :app_ver => app_ver)
        else
          user_gcm_key = UserGcmKey.create(:user_id => current_user.id, :gcm_key => gcm_key, :device_id => device_id, :app_ver => app_ver)
        end
      else
        # 로그아웃한 경우 또는 앱을 삭제했다가 다시 설치한 경우 기존 정보 제거
        # 단, 앱 삭제시에는 캐치할 수 없고, 앱 삭제 후 재설치한 직후(1회)에는 cookie 설정이 한템포 늦으므로 타이밍 오류 있음
        UserGcmKey.where(:device_id => device_id).destroy_all unless device_id == nil
      end

      # 앱 뱃지 카운트 초기화
      if user_gcm_key != nil && app_ver != nil
        registration_ids = []
        registration_ids << user_gcm_key.gcm_key
        if current_user
          alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(20)
          count = alrams.where(:is_read => false).count
        else
          count = 0
        end
        push_send(registration_ids, "false", count, "", "", "")
      end
    end
  end

  private
  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      :user_string_id => current_user ? current_user.string_id : "visitor"
    }
  end

end
