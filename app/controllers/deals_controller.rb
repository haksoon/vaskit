class DealsController < ApplicationController
  CONFIG = YAML.load_file(Rails.root.join('config/naver.yml'))[Rails.env]
  CLIENT_ID = CONFIG['client_id']
  CLIENT_SECRET = CONFIG['client_secret']

  # GET /deals/get_naver_deals.json
  def get_naver_deals
    shop_result = nil

    unless params[:page].blank? && params[:keyword].blank?
      keyword = params[:keyword]
      page = Deal::NAVER_RESULT_PER * (params[:page].to_i - 1) + 1

      shop_url = URI.encode("https://openapi.naver.com/v1/search/shop.xml?query=#{keyword}&display=#{Deal::NAVER_RESULT_PER}&start=#{page}&sort=sim")
      shop_uri = URI.parse(shop_url)
      shop_http = Net::HTTP.new(shop_uri.host, shop_uri.port)
      shop_http.use_ssl = true
      shop_http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      shop_request = Net::HTTP::Get.new(shop_uri.request_uri)
      shop_request.initialize_http_header('X-Naver-Client-Id' => CLIENT_ID, 'X-Naver-Client-Secret' => CLIENT_SECRET)
      shop_response = shop_http.request(shop_request)
      shop_doc = Nokogiri::XML(shop_response.body)
      shop_result = Hash.from_xml(shop_doc.to_s)['rss']['channel']['item']
    end

    render json: { shop_result: shop_result }
  end

  # GET /deals/get_naver_images.json
  # def get_naver_images
  #   image_result = nil
  #
  #   unless params[:page].blank? && params[:keyword].blank?
  #     keyword = params[:keyword]
  #     page = Deal::NAVER_RESULT_PER * (params[:page].to_i - 1) + 1
  #
  #     image_url = URI.encode("https://openapi.naver.com/v1/search/image.xml?query=#{keyword}&display=#{Deal::NAVER_RESULT_PER}&start=#{page}&sort=sim")
  #     image_uri = URI.parse(image_url)
  #     image_http = Net::HTTP.new(image_uri.host, image_uri.port)
  #     image_http.use_ssl = true
  #     image_http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  #     image_request = Net::HTTP::Get.new(image_uri.request_uri)
  #     image_request.initialize_http_header('X-Naver-Client-Id' => CLIENT_ID, 'X-Naver-Client-Secret' => CLIENT_SECRET)
  #     image_response = image_http.request(image_request)
  #     image_doc = Nokogiri::XML(image_response.body)
  #     image_result = Hash.from_xml(image_doc.to_s)['rss']['channel']['item']
  #   end
  #
  #   render json: { image_result: image_result }
  # end

  # POST /deals/create_by_naver.json
  def create_by_naver
    naver_deal = params[:item]

    title = ActionView::Base.full_sanitizer.sanitize(naver_deal[:title])
    brand = nil
    price = naver_deal[:lprice]
    link = nil
    image = open(naver_deal[:image])
    product_id = naver_deal[:productId]

    redirect_link = open(naver_deal[:link]).read.split("'")[1]
    if !redirect_link.include?('http') || redirect_link.include?('shopping.naver.com')
        # 네이버 쇼핑 페이지 : 브랜드 파싱 시도
        naver_shop_link = "http://shopping.naver.com#{redirect_link}"
        naver_shop_doc = Nokogiri::HTML(open(naver_shop_link).read, nil, 'utf-8')

        brand1 = ''
        brand2 = ''
        if !naver_shop_doc.css('.info_inner span').empty?
          info = naver_shop_doc.css('.info_inner span')
          brand1 = info[0].text
          brand2 = info[1].text
        end

        brand =
          if brand1.include?('브랜드')
            ActionView::Base.full_sanitizer.sanitize(brand1.tr('브랜드 ', ''))
          elsif brand2.include?('브랜드')
            ActionView::Base.full_sanitizer.sanitize(brand2.tr('브랜드 ', ''))
          elsif brand1.include?('제조사')
            ActionView::Base.full_sanitizer.sanitize(brand1.tr('제조사 ', ''))
          elsif brand2.include?('제조사')
            ActionView::Base.full_sanitizer.sanitize(brand2.tr('제조사 ', ''))
          end

        naver_mall = naver_shop_doc.css('.mall_area div span a')[0]
        unless naver_mall.nil?
          # 판매자가 없을 경우를 배제함
          naver_passing_page_link = naver_mall.attr('href')
          naver_passing_page = Nokogiri::HTML(open(naver_passing_page_link).read, nil, 'utf-8')
          if naver_passing_page.to_s.include?('targetUrl')
            # 외부 쇼핑몰
            redirect_shop_link = /(targetUrl).*/.match(naver_passing_page.to_s)[0].split('"')[1]
            link = open("http://cr2.shopping.naver.com#{redirect_shop_link}").base_uri.to_s
          else
            # 스토어팜
            link = open(naver_passing_page_link).base_uri.to_s
          end
        end
    elsif redirect_link.include?('storefarm.naver.com')
      # 네이버 스토어팜 페이지 : 브랜드 파싱 시도
      store_farm_doc = Nokogiri::HTML(open(redirect_link).read, nil, 'utf-8')

      brand =
        unless store_farm_doc.css('.goods_component .detail_view table').empty?
          trs = store_farm_doc.css('.goods_component .detail_view>table>tbody>tr')
          table = Hash.new
          trs.css('th').each_with_index { |th, index| table[th.text] = index }
          trs.css('td')[table['제조사']].text unless table['제조사'].nil?
          trs.css('td')[table['제조사']].text unless table['브랜드'].nil?
        end

      brand = naver_deal[:mallName] if brand.nil? && naver_deal[:mallName] != '네이버'
      link = redirect_link
    else
      # 네이버 쇼핑 외 페이지 : 브랜드 파싱 어려움
      link = redirect_link
    end

    deal = Deal.find_by_product_id(product_id)

    if deal.nil?
      deal = Deal.create(title: title,
                         brand: brand,
                         price: price,
                         link: link,
                         image: image,
                         product_id: product_id)
    else
      deal.update(title: title,
                  brand: brand,
                  price: price,
                  link: link,
                  image: image)
    end

    preview_image = PreviewImage.create(user_id: current_user.id, image: naver_deal[:image])

    render json: { deal: deal,
                   image_url: preview_image.image.url(:square),
                   preview_img_id: preview_image.id }
  end
end
