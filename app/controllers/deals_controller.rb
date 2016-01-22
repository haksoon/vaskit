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
    
    xml_doc  = Nokogiri::XML(open(URI.encode("http://openapi.naver.com/search?key=fd787e8dbbd5217bd4b704d8c1b85e56&query=#{params[:keyword]}&display=7&start=1&target=shop&sort=sim")).read)
    result = Hash.from_xml(xml_doc.to_s)
    
    render :json => {:result => result}
  end
  
  #POST /deals/create_by_naver.json
  def create_by_naver
    naver_deal = params[:item]
    title = ActionView::Base.full_sanitizer.sanitize(naver_deal[:title])
    # naver_shop = Nokogiri::HTML(open(deal[:link]).read, nil ,'utf-8')
    image = open(naver_deal[:image])
    product_id = naver_deal[:productId]
    deal = Deal.find_by_product_id(product_id)
    if deal.blank?
      deal = Deal.create(:title => title, :brand => naver_deal[:mallName], :price => naver_deal[:lprice], :link => naver_deal[:link], :image => image, :product_id => naver_deal[:productId])
    end
    render :json => {:deal => deal}
  end
   
end
