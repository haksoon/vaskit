# coding : utf-8
require 'open-uri'

class DealsController < ApplicationController
  
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    Deal.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
  #GET /deals/get_naver_deals.json
  def get_naver_deals
    shop_doc  = Nokogiri::XML(open(URI.encode("http://openapi.naver.com/search?key=fd787e8dbbd5217bd4b704d8c1b85e56&query=#{params[:keyword]}&display=30&start=1&target=shop&sort=sim")).read)
    shop_result = Hash.from_xml(shop_doc.to_s)
    image_doc  = Nokogiri::XML(open(URI.encode("http://openapi.naver.com/search?key=fd787e8dbbd5217bd4b704d8c1b85e56&query=#{params[:keyword]}&display=51&start=1&target=image&sort=sim")).read)
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
      brand = ActionView::Base.full_sanitizer.sanitize(naver_shop_doc.css(".tit span")[2].to_s).tr("브랜드 ","")
      naver_passing_page_link = naver_shop_doc.css(".mall_area div span a")[0].attr("href")
      naver_passing_page = Nokogiri::HTML(open(naver_passing_page_link).read, nil, 'utf-8')
      if naver_passing_page.to_s.include?("targetUrl")  #외부 쇼핑몰
        redirect_shop_link = /(targetUrl).*/.match(naver_passing_page.to_s)[0].split('"')[1]
        link = open("http://cr2.shopping.naver.com" + redirect_shop_link).base_uri.to_s
      else #스토어팜
        link = open(naver_passing_page_link).base_uri.to_s
      end
    end
    
    image = open(naver_deal[:image])
    product_id = naver_deal[:productId]
    deal = Deal.find_by_product_id(product_id)
    if deal.blank?
      deal = Deal.create(:title => title, :brand => brand, :price => naver_deal[:lprice], :link => link, :image => image, :product_id => naver_deal[:productId])
    end
    render :json => {:deal => deal}
  end
   
end
