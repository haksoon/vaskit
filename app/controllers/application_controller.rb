class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :detect_browser, :set_visitor, :prepare_exception_notifier

  MOBILE_BROWSERS = ["android", "iphone", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

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
    if current_user
      unless cookies["gcm_key"] == nil
        gcm_key = cookies["gcm_key"]
        device_id = cookies["device_id"]
        UserGcmKey.where(:device_id => device_id).destroy_all unless device_id == nil
        user_gcm_key = UserGcmKey.find_by(:gcm_key => gcm_key)
        if user_gcm_key
          user_gcm_key.update(:user_id => current_user.id)
        else
          UserGcmKey.create(:user_id => current_user.id, :gcm_key => gcm_key, :device_id => device_id)
        end
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
