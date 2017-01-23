# coding : utf-8
class SearchController < ApplicationController

  # GET /search
  # GET /search?type=___&keyword=___
  def index
    @type = params[:type]
    @keyword = params[:keyword]

    case @type
        when "hash_tag"
          hash_tags = HashTag.where("keyword LIKE ?", "%#{@keyword}%")
          @asks = Ask.where(id: hash_tags.map(&:ask_id))
                     .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                     .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
        when "ask_deal"
          ask_deals = AskDeal.where("title LIKE ?", "%#{@keyword}%")
          @asks = Ask.where("left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)", ask_deals.map(&:id), ask_deals.map(&:id))
                     .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                     .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ]) unless ask_deals.blank?
        when "brand"
          ask_deals = AskDeal.where("brand LIKE ?", "%#{@keyword}%")
          @asks = Ask.where("left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)", ask_deals.map(&:id), ask_deals.map(&:id))
                     .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                     .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ]) unless ask_deals.blank?
        when "user"
          users = User.where("string_id LIKE ?", "%#{@keyword}%")
          @asks = Ask.where(user_id: users.map(&:id))
                     .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                     .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
        when "none" #통합 검색
          user_ask_ids = Ask.where(user_id: User.where("string_id LIKE ?", "%#{@keyword}%").pluck(:id)).pluck(:id)
          hash_tag_ask_ids = Ask.where(id: HashTag.where("keyword LIKE ?", "%#{@keyword}%" ).pluck(:ask_id) ).pluck(:id)
          title_ask_deal_ids = AskDeal.where("title LIKE ?", "%#{@keyword}%" ).pluck(:id)
          title_ask_ids = Ask.where("left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)", title_ask_deal_ids, title_ask_deal_ids).pluck(:id)
          brand_ask_deal_ids = AskDeal.where("brand LIKE ?", "%#{@keyword}%" ).pluck(:id)
          brand_ask_ids = Ask.where("left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)", brand_ask_deal_ids, brand_ask_deal_ids).pluck(:id)
          ask_ids = (user_ask_ids + hash_tag_ask_ids + title_ask_ids + brand_ask_ids).uniq
          @asks = Ask.where(id: ask_ids)
                     .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                     .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :ask_complete, :votes, :ask_likes, {comments: {include: :user}} ])
    end

    respond_to do |format|
      format.html {}
      format.json {
        render :json => {asks: @asks}
      }
    end
  end

  # GET /search/get_keyword.json?keyword=___
  def get_keyword
    keyword = params[:keyword]
    users = []
    hash_tags = []
    ask_deals = []
    brand = false
    is_empty_result = false
    unless keyword.blank?
      collection_keywords = CollectionKeyword.where("keyword LIKE ?", "%#{keyword}%").order(refer_count: :desc)
      related_collections = CollectionToCollectionKeyword.where(collection_keyword_id: collection_keywords.map(&:id))
      collections = Collection.where(id: related_collections.map(&:collection_id)).select(:id, :name).distinct(:name)

      hash_tags = HashTag.where("keyword LIKE ?", "%#{keyword}%").select(:keyword).distinct(:keyword)

      ask_deal = true unless AskDeal.where("title LIKE ?", "%#{keyword}%" ).blank?

      brand = true unless AskDeal.where("brand LIKE ?", "%#{keyword}%" ).blank?

      asks = Ask.all.select(:user_id).distinct(:user_id)
      users = User.where("string_id LIKE ?", "%#{keyword}%").where(id: asks.map(&:user_id)).select(:string_id).distinct(:string_id) #AJS추가(수정) - 유저의 경우에도 string_id가 keyword가 되도록 로직 변경
    end
    is_empty_result = true if users.blank? && hash_tags.blank? && ask_deals.blank? && brand.blank?
    render :json => {collections: collections, hash_tags: hash_tags, ask_deal: ask_deal, brand: brand, users: users, is_empty_result: is_empty_result}
  end

end
