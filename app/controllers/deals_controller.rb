# coding : utf-8
require 'open-uri'

class DealsController < ApplicationController

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
    shop_request.initialize_http_header({"X-Naver-Client-Id" => client_id, "X-Naver-Client-Secret" => client_secret})
    shop_response = shop_http.request(shop_request)
    shop_doc = Nokogiri::XML(shop_response.body)
    shop_result = Hash.from_xml(shop_doc.to_s)

    image_url = URI.encode("https://openapi.naver.com/v1/search/image.xml?query=#{params[:keyword]}&display=51&start=1&sort=sim")
    image_uri = URI.parse(image_url)
    image_http = Net::HTTP.new(image_uri.host, image_uri.port)
    image_http.use_ssl = true
    image_http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    image_request = Net::HTTP::Get.new(image_uri.request_uri)
    image_request.initialize_http_header({"X-Naver-Client-Id" => client_id, "X-Naver-Client-Secret" => client_secret})
    image_response = image_http.request(image_request)
    image_doc = Nokogiri::XML(image_response.body)
    image_result = Hash.from_xml(image_doc.to_s)

    render json: { shop_result: shop_result, image_result: image_result }
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

      if naver_shop_doc.css(".tit span").size > 0
        brand1 = naver_shop_doc.css(".tit span")[0].text
        brand2 = naver_shop_doc.css(".tit span")[2].text
      elsif naver_shop_doc.css(".info_inner span").size > 0
        brand1 = naver_shop_doc.css(".info_inner span")[0].text
        brand2 = naver_shop_doc.css(".info_inner span")[2].text
      else
        brand1 = ""
        brand2 = ""
      end
      brand = ActionView::Base.full_sanitizer.sanitize(brand1.tr("브랜드 ","")) if brand1.include?("브랜드")
      brand = ActionView::Base.full_sanitizer.sanitize(brand2.tr("브랜드 ","")) if brand.nil? && brand2.include?("브랜드")
      brand = ActionView::Base.full_sanitizer.sanitize(brand1.tr("제조사 ","")) if brand.nil? && brand1.include?("제조사")
      brand = ActionView::Base.full_sanitizer.sanitize(brand2.tr("제조사 ","")) if brand.nil? && brand2.include?("제조사")

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
      deal = Deal.create(title: title, brand: brand, price: naver_deal[:lprice], link: link, image: image, product_id: product_id)
    end

    preview_image = PreviewImage.create(user_id: current_user.id, image: naver_deal[:image])
    image_url = preview_image.image.url(:square) unless preview_image.image.blank?

    render json: { deal: deal, image_url: image_url, preview_img_id: preview_image.id }

    # shopping_url = URI.encode("http://shopping.naver.com/search/all.nhn?query=#{product_id}")
    # shopping_uri = URI.parse(shopping_url)
    # shopping_tmp_file = open(shopping_uri)
    # shopping_doc = Nokogiri::HTML(shopping_tmp_file, nil, "utf-8")
    # shopping_product = shopping_doc.css(".content_area .goods_list>li")[0]
    # unless shopping_product == nil
    #   shopping_categories = shopping_product.css(".info .depth a")
    #   shopping_categories_size = shopping_categories.size - 1
    #   shopping_category_id = shopping_categories[shopping_categories_size].attribute("href").value.gsub("/category/category.nhn?cat_id=", "")
    #   deal_category_id = DealCategory.find_by_category_id(shopping_category_id).id
    # end

    # shopping_categories = shopping_product.css(".info .depth a").children
    # categories = []
    # shopping_categories.each do |shopping_category|
    #   categories << shopping_category.text
    # end
    # category_1 = categories[0]
    # category_2 = categories[1]
    # category_3 = categories[2]
    # category_4 = categories[3]

    # if deal.blank?
    #   deal = Deal.create(:title => title, :brand => brand, :price => naver_deal[:lprice], :link => link, :image => image, :product_id => naver_deal[:productId], :deal_category_id => deal_category_id)
    # else
    #   deal = deal.update(:deal_category_id => deal_category_id)
    # end
  end


  # 네이버 카테고리 가져오기 임시
  # def category_setting
  #     for i in 50000000..50000010
  #       url = URI.encode("http://shopping.naver.com/category/category.nhn?cat_id=#{i}")
  #       uri = URI.parse(url)
  #       tmp_file = open(uri)
  #       doc = Nokogiri::HTML(tmp_file, nil, "utf-8")
  #
  #       category_1_id = "#{i}"
  #       category_1_name = doc.css("h2.category_tit").text
  #       DealCategory.create(:category_id => category_1_id, :category_1 => category_1_name)
  #
  #       category_1_lists = doc.css("div.category_col")
  #       category_1_lists.each do |category_1_list|
  #         category_2_lists = category_1_list.css("h3")
  #         category_2_lists.each do |category_2_list|
  #           category_2_link = category_2_list.css("a")
  #           unless category_2_link.size == 0
  #             category_2_link_href = category_2_link.attribute("href")
  #             unless category_2_link_href == nil
  #               category_2_link_href = category_2_link_href.value.gsub("/category/category.nhn?cat_id=", "")
  #               category_2_name = category_2_link.children[0].text
  #               if category_2_link_href.length == 8
  #                 DealCategory.create(:category_id => category_2_link_href, :category_1 => category_1_name, :category_2 => category_2_name)
  #               end
  #               category_3_lists = category_1_list.css(".category_list>li")
  #               category_3_lists.each do |category_3_list|
  #                 category_3_link = category_3_list.css(">a")
  #                 unless category_3_link.size == 0
  #                   category_3_link_href = category_3_link.attribute("href")
  #                   unless category_3_link_href == nil
  #                     category_3_link_href = category_3_link_href.value.gsub("/category/category.nhn?cat_id=", "")
  #                     category_3_name = category_3_link.children[0].text
  #                     if category_3_link_href.length == 8
  #                       DealCategory.create(:category_id => category_3_link_href, :category_1 => category_1_name, :category_2 => category_2_name, :category_3 => category_3_name)
  #                     end
  #                     if category_3_list.css("a").size > 1
  #                       category_4_lists = category_3_list.css(">ul>li")
  #                       category_4_lists = category_3_list.css(".ly_category_list>ul>li") if category_4_lists.size == 0
  #                       category_4_lists.each do |category_4_list|
  #                         category_4_link = category_4_list.css(">a")
  #                         unless category_4_link.size == 0
  #                           category_4_link_href = category_4_link.attribute("href")
  #                           unless category_4_link_href == nil
  #                             category_4_link_href = category_4_link_href.value.gsub("/category/category.nhn?cat_id=", "")
  #                             category_4_name = category_4_link.children[0].text
  #                             if category_4_link_href.length == 8
  #                               DealCategory.create(:category_id => category_4_link_href, :category_1 => category_1_name, :category_2 => category_2_name, :category_3 => category_3_name, :category_4 => category_4_name)
  #                             end
  #                           end
  #                         end
  #                       end
  #                     end
  #                   end
  #                 end
  #               end
  #             end
  #           end
  #         end
  #       end
  #     end
  # end

end
