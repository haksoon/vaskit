class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :set_visitor, unless: -> { request.format.json? }
  before_action :user_visits, unless: -> { request.format.json? }
  before_action :auth_app, unless: -> { request.format.json? }
  before_action :prepare_exception_notifier

  include PushSend

  def set_visitor
    @uniq_key = cookies['visitor_key']
    rand_key = Time.now.to_f.to_s + rand(1_000_000).to_s
    if @uniq_key.blank?
      @uniq_key = rand_key
      @visitor = Visitor.create(uniq_key: Digest::MD5.hexdigest(@uniq_key),
                                remote_ip: remote_ip)
    else
      @visitor = Visitor.find_by_uniq_key(Digest::MD5.hexdigest(@uniq_key))
      if @visitor.nil?
        cookies['visitor_key'] = { value: rand_key,
                                   expires: 3.months.from_now,
                                   path: '/' }
        @uniq_key = cookies['visitor_key']
        @visitor = Visitor.create(uniq_key: Digest::MD5.hexdigest(@uniq_key),
                                  remote_ip: remote_ip)
      end
    end
  end

  def user_visits
    ua = request.headers['User-Agent'] ? request.headers['User-Agent'] : 'unknown'
    device =
      if ua =~ /iPhone/i
        'iPhone'
      elsif ua =~ /Android/i
        'Android'
      elsif ua =~ /Win|Windows/i
        'Windows'
      elsif ua =~ /Mac|MacIntel/i
        'Mac'
      elsif ua =~ /Linux/i
        'Linux'
      elsif ua =~ /iPod|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson/i
        'mobile_etc'
      else
        'unknown'
      end

    browser =
      if ua =~ /VASKIT_IOS_APP/i
        'VASKIT_IOS_APP'
      elsif ua =~ /VASKIT_AOS_APP/i
        'VASKIT_AOS_APP'
      elsif ua =~ /NAVER/i
        'NaverAPP'
      elsif ua =~ /Daum/i
        'DaumAPP'
      elsif ua =~ /KAKAOTALK|KAKAOSTORY/i
        'KakaoAPP'
      elsif ua =~ /Facebook|FB/i
        'FacebookAPP'
      elsif ua =~ /MSIE|Trident/i
        'IE'
      elsif ua =~ /Edge/i
        'Edge'
      elsif ua =~ /Opera|OPR|OPiOS/i
        'Opera'
      elsif ua =~ /Chrome|CriOS/i
        'Chrome'
      elsif ua =~ /Firefox|FxiOS/i
        'FireFox'
      elsif ua =~ /Safari/i
        'Safari'
      else
        'unknown'
      end

    referer_host = request.referer ? URI.parse(URI.encode(request.referer.strip)).host.to_s : 'None'
    referer = request.referer ? URI.parse(URI.encode(request.referer.strip)).to_s : 'None'

    set_visitor
    user_id = current_user.id unless current_user.blank?
    visitor_id = @visitor.id unless @visitor.blank?

    if current_user && referer_host == request.host
      user_visit = UserVisit.where(visitor_id: @visitor.id).last
      if user_visit && Time.now - user_visit.updated_at < 60 * 60 * 24
        user_visit.update(user_id: user_id)
      else
        UserVisit.create(user_id: user_id,
                         visitor_id: visitor_id,
                         device: device,
                         browser: browser,
                         referer_host: referer_host,
                         referer_full: referer,
                         user_agent: ua)
      end
    else
      UserVisit.create(user_id: user_id,
                       visitor_id: visitor_id,
                       device: device,
                       browser: browser,
                       referer_host: referer_host,
                       referer_full: referer,
                       user_agent: ua)
    end
  end

  def remote_ip
    ret = !request.env['HTTP_X_FORWARDED_FOR'].nil? ? request.env['HTTP_X_FORWARDED_FOR'] : request.env['REMOTE_ADDR']
    ret.split(',')[0]
  end

  private

  def auth_app
    return unless cookies['_vaskit_session'].nil? && !cookies['app_user'].blank?
    crypt = ActiveSupport::MessageEncryptor.new('24136565f7bb1cdc129a4c6e8209abe831d43b858e9ce9ce70f27a914a0fb60c8098b3f417e16232c4575bd0dd9ee47ac8eac90eaef5894a7044cc6a892f5cb9')
    app_user = crypt.decrypt_and_verify(cookies['app_user'])
    resource = User.find_for_database_authentication(id: app_user)
    return if resource.blank?
    sign_in(:user, resource)
    resource.remember_me!
  end

  def auth_app_create(user)
    if user.nil?
      cookies.delete :app_user
    elsif user && user.sign_up_type != 'facebook'
      return unless cookies['_vaskit_session'].nil?
      crypt = ActiveSupport::MessageEncryptor.new('24136565f7bb1cdc129a4c6e8209abe831d43b858e9ce9ce70f27a914a0fb60c8098b3f417e16232c4575bd0dd9ee47ac8eac90eaef5894a7044cc6a892f5cb9')
      app_user = crypt.encrypt_and_sign(user.id)
      cookies['app_user'] = { value: app_user,
                              expires: 3.months.from_now,
                              path: '/' }
    end
  end

  def prepare_exception_notifier
    request.env['exception_notifier.exception_data'] = {
      user_string_id: current_user ? current_user.string_id : 'visitor',
      ip_adress: remote_ip
    }
  end
end
