class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :set_visitor, unless: -> { request.format.json? }
  before_action :user_visits, unless: -> { request.format.json? }
  before_action :prepare_exception_notifier

  include PushSend

  def set_visitor
    @uniq_key = cookies["visitor_key"]
    if @uniq_key.blank?
      @uniq_key = Time.now.to_f.to_s + rand(1000000).to_s
      @visitor = Visitor.create(uniq_key: Digest::MD5.hexdigest(@uniq_key), remote_ip: get_remote_ip)
    else
      @visitor = Visitor.find_by_uniq_key(Digest::MD5.hexdigest(@uniq_key))
    end
  end

  def user_visits
    ua = request.headers['User-Agent'] ? request.headers['User-Agent'] : "unknown"
    if ua.match(/iPhone/i)
        device = "iPhone"
    elsif ua.match(/Android/i)
        device = "Android"
    elsif ua.match(/Win|Windows/i)
        device = "Windows"
    elsif ua.match(/Mac|MacIntel/i)
        device = "Mac"
    elsif ua.match(/Linux/i)
        device = "Linux"
    elsif ua.match(/iPod|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson/i)
        device = "mobile_etc"
    else
        device = "unknown"
    end

    if ua.match(/NAVER/i)
        browser = "NaverAPP"
    elsif ua.match(/Daum/i)
        browser = "DaumAPP"
    elsif ua.match(/KAKAOTALK|KAKAOSTORY/i)
        browser = "KakaoAPP"
    elsif ua.match(/Facebook|FB/i)
        browser = "FacebookAPP"
    elsif ua.match(/MSIE|Trident/i)
        browser = "IE"
    elsif ua.match(/Edge/i)
        browser = "Edge"
    elsif ua.match(/Opera|OPR|OPiOS/i)
        browser = "Opera"
    elsif ua.match(/Chrome|CriOS/i)
        browser = "Chrome"
    elsif ua.match(/Firefox|FxiOS/i)
        browser = "FireFox"
    elsif ua.match(/Safari/i)
        browser = "Safari"
    else
        browser = "unknown"
    end

    referer_host = request.referer ? URI.parse(URI.encode(request.referer.strip)).host.to_s : "None"
    referer = request.referer ? URI.parse(URI.encode(request.referer.strip)).to_s : "None"

    set_visitor
    user_id = current_user.id unless current_user.blank?
    visitor_id = @visitor.id unless @visitor.blank?

    if current_user && referer_host == request.host
      user_visit = UserVisit.where(visitor_id: @visitor.id).last
      if user_visit && Time.now - user_visit.updated_at < 60 * 60 * 24
        user_visit.update(user_id: user_id)
      else
        UserVisit.create(user_id: user_id, visitor_id: visitor_id, device: device, browser: browser, referer_host: referer_host, referer_full: referer, user_agent: ua)
      end
    else
      UserVisit.create(user_id: user_id, visitor_id: visitor_id, device: device, browser: browser, referer_host: referer_host, referer_full: referer, user_agent: ua)
    end
  end

  def get_remote_ip
    ret = request.env["HTTP_X_FORWARDED_FOR"] != nil ? request.env["HTTP_X_FORWARDED_FOR"] : request.env["REMOTE_ADDR"]
    return ret.split(",")[0]
  end

  private
  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      user_string_id: current_user ? current_user.string_id : "visitor",
      ip_adress: get_remote_ip
    }
  end

end
