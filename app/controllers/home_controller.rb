class HomeController < ApplicationController
  # GET /
  def index
  end

  # GET /landing
  def landing
  end

  # GET /open_app
  def open_app
    device = params[:device]
    browser = params[:browser]
    app_url = params[:app_url]
    app_js = params[:app_js]
    connect_to_store = params[:connect_to_store]

    if device == 'iPhone'
      app_link = "fb532503193593128://kr.vaskit.msh.vaskit.fb532503193593128?js=#{app_js}"
      store_link = 'http://itunes.apple.com/kr/app/id1188969345?mt=8'
      if connect_to_store == 'true'
        @link_1 = app_link
        @link_2 = store_link
        if browser == 'FacebookAPP' || browser == 'NaverAPP'
          @link_1 = store_link
          @link_2 = app_link
        end
      else
        @link_1 = app_link
        @link_2 = app_url
      end
    elsif device == 'Android'
      intent_link = "intent://vaskit.kr?url=#{app_url}&js=#{app_js}#Intent;scheme=vaskit;action=android.intent.action.VIEW;category=android.intent.category.BROWSABLE;package=com.vaskit.msh.vaskit;end"
      app_link = "vaskit://vaskit.kr?url=#{app_url}&js=#{app_js}"
      store_link = 'https://play.google.com/store/apps/details?id=com.vaskit.msh.vaskit'

      @link_1 =
        if browser == 'Chrome' || browser == 'FacebookAPP' || browser == 'NaverAPP' || browser == 'KakaoAPP'
          intent_link
        else
          app_link
        end

      if connect_to_store == 'true'
        @link_2 = store_link
      else
        @link_2 = app_url
      end
    end

    render layout: 'blank'
  end
end
