# coding : utf-8
require 'open-uri'

class DealsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  #GET /deals/get_naver_deals.json
  def get_naver_deals
    config = YAML.load_file(Rails.root.join("config/naver.yml"))[Rails.env]
    client_id = config['client_id']
    client_secret = config['client_secret']

    shop_url = URI.encode("https://openapi.naver.com/v1/search/shop.xml?query=#{params[:keyword]}&display=30&start=1&sort=sim")
    shop_uri = URI.parse(shop_url)
    shop_http = Net::HTTP.new(shop_uri.host, shop_uri.port)
    shop_http.use_ssl = true
    shop_http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    shop_request = Net::HTTP::Get.new(shop_uri.request_uri)
    shop_request.initialize_http_header({"X-Naver-Client-Id"=>client_id, "X-Naver-Client-Secret"=> client_secret})
    shop_response = shop_http.request(shop_request)
    shop_doc = Nokogiri::XML(shop_response.body)
    shop_result = Hash.from_xml(shop_doc.to_s)

    image_url = URI.encode("https://openapi.naver.com/v1/search/image.xml?query=#{params[:keyword]}&display=51&start=1&sort=sim")
    image_uri = URI.parse(image_url)
    image_http = Net::HTTP.new(image_uri.host, image_uri.port)
    image_http.use_ssl = true
    image_http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    image_request = Net::HTTP::Get.new(image_uri.request_uri)
    image_request.initialize_http_header({"X-Naver-Client-Id"=>client_id, "X-Naver-Client-Secret"=> client_secret})
    image_response = image_http.request(image_request)
    image_doc = Nokogiri::XML(image_response.body)
    image_result = Hash.from_xml(image_doc.to_s)

    render :json => {:shop_result => shop_result, :image_result => image_result}
  end

  #POST /deals/create_by_naver.json
  def create_by_naver
    naver_deal = params[:item]
    title = ActionView::Base.full_sanitizer.sanitize(naver_deal[:title])

    brand = nil
    link = nil
    redirect_link = open(naver_deal[:link]).read

    if redirect_link.split("'")[1].include?("http")
      link = redirect_link.split("'")[1]
    else
      naver_shop_link = "http://shopping.naver.com" + open(naver_deal[:link]).read.split("'")[1]
      naver_shop_doc = Nokogiri::HTML(open(naver_shop_link).read, nil, 'utf-8')

      brand1 = naver_shop_doc.css(".tit span")[0].text
      brand2 = naver_shop_doc.css(".tit span")[2].text
      brand = ActionView::Base.full_sanitizer.sanitize(brand1.tr("브랜드 ","")) if brand1.include?("브랜드")
      brand = ActionView::Base.full_sanitizer.sanitize(brand2.tr("브랜드 ","")) if brand.blank? && brand2.include?("브랜드")
      brand = ActionView::Base.full_sanitizer.sanitize(brand1.tr("제조사 ","")) if brand.blank? && brand1.include?("제조사")
      brand = ActionView::Base.full_sanitizer.sanitize(brand2.tr("제조사 ","")) if brand.blank? && brand2.include?("제조사")

      naver_mall = naver_shop_doc.css(".mall_area div span a")[0]
      unless naver_mall.nil? #판매자가 없을 경우를 배제함
        naver_passing_page_link = naver_mall.attr("href")
        naver_passing_page = Nokogiri::HTML(open(naver_passing_page_link).read, nil, 'utf-8')
        if naver_passing_page.to_s.include?("targetUrl")  #외부 쇼핑몰
          redirect_shop_link = /(targetUrl).*/.match(naver_passing_page.to_s)[0].split('"')[1]
          link = open("http://cr2.shopping.naver.com" + redirect_shop_link).base_uri.to_s
        else #스토어팜
          link = open(naver_passing_page_link).base_uri.to_s
        end
      end
    end

    image = open(naver_deal[:image])
    product_id = naver_deal[:productId]
    deal = Deal.find_by_product_id(product_id)
    if deal.blank?
      deal = Deal.create(:title => title, :brand => brand, :price => naver_deal[:lprice], :link => link, :image => image, :product_id => naver_deal[:productId])
    end

    preview_image = PreviewImage.create(:user_id => current_user.id, :image => params[:item][:image])
    image_url = preview_image.image.url(:crop) unless preview_image.image.blank?

    render :json => {:deal => deal, :image_url => image_url, :id => preview_image.id}
  end

  def destroy
    Deal.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
end
