class SearchController < ApplicationController
  after_action :search_logging, only: :index

  # GET /search
  # GET /search?type=___&keyword=___
  def index
    @type = params[:type]
    @keyword = params[:keyword]

    respond_to do |format|
      format.html
      format.json do
        if params[:search_keywords]
          search_keywords = SearchKeyword.order(list_order: :asc)
          render json: { search_keywords: search_keywords }
        else
          @asks =
            case @type
            when 'hash_tag'
              hash_tags = HashTag.where('keyword LIKE ?', "%#{@keyword}%")
              Ask.where(id: hash_tags.map(&:ask_id))
            when 'ask_deal'
              ask_deals = AskDeal.where('title LIKE ?', "%#{@keyword}%")
              Ask.where('left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)',
                        ask_deals.map(&:id),
                        ask_deals.map(&:id)) unless ask_deals.blank?
            when 'brand'
              ask_deals = AskDeal.where('brand LIKE ?', "%#{@keyword}%")
              Ask.where('left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)',
                        ask_deals.map(&:id),
                        ask_deals.map(&:id)) unless ask_deals.blank?
            when 'user'
              users = User.where('string_id LIKE ?', "%#{@keyword}%")
              Ask.where(user_id: users.map(&:id))
            when 'none'
              ask_ids = []
              hash_tags = HashTag.where('keyword LIKE ?', "%#{@keyword}%")
              title_ask_deals = AskDeal.where('title LIKE ?', "%#{@keyword}%")
              brand_ask_deals = AskDeal.where('brand LIKE ?', "%#{@keyword}%")
              users = User.where('string_id LIKE ?', "%#{@keyword}%")

              ask_ids << Ask.where(user_id: users.map(&:id)).pluck(:id)
              ask_ids << Ask.where(id: hash_tags.map(&:ask_id)).pluck(:id)
              ask_ids << Ask.where('left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)',
                                   title_ask_deals.map(&:id),
                                   title_ask_deals.map(&:id)).pluck(:id)
              ask_ids << Ask.where('left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)',
                                   brand_ask_deals.map(&:id),
                                   brand_ask_deals.map(&:id)).pluck(:id)
              Ask.where(id: ask_ids)
            end
          @asks = @asks.page(params[:page])
                       .per(Ask::ASK_PER)
                       .order(id: :desc)
                       .as_json(include: [:user, :left_ask_deal, :right_ask_deal, :votes, :ask_likes, :ask_complete, :event])
          render json: { asks: @asks }
        end
      end
    end
  end

  # GET /search/keyword.json?keyword=___
  def keyword
    keyword = params[:keyword]
    hash_tags = []
    ask_deals = []
    brands = []
    users = []
    is_empty_result = false
    unless keyword.blank?
      collection_keywords = CollectionKeyword.where('keyword LIKE ?', "%#{keyword}%").order(refer_count: :desc)
      related_collections = CollectionToCollectionKeyword.where(collection_keyword_id: collection_keywords.map(&:id))
      collections = Collection.where(id: related_collections.map(&:collection_id)).select(:id, :name).distinct(:name)

      hash_tags = HashTag.where('keyword LIKE ?', "%#{keyword}%").select(:keyword).distinct(:keyword)
      ask_deals = AskDeal.where('title LIKE ?', "%#{keyword}%").select(:title).distinct(:title)
      brands = AskDeal.where('brand LIKE ?', "%#{keyword}%").select(:brand).distinct(:brand)
      asks = Ask.all.select(:user_id).distinct(:user_id)
      users = User.where('string_id LIKE ?', "%#{keyword}%")
                  .where(id: asks.map(&:user_id)).select(:string_id).distinct(:string_id)
    end
    is_empty_result = true if users.blank? && hash_tags.blank? && ask_deals.blank? && brands.blank?
    render json: { collections: collections,
                   hash_tags: hash_tags,
                   ask_deals: ask_deals,
                   brands: brands,
                   users: users,
                   is_empty_result: is_empty_result }
  end

  private

  def search_logging
    return if params[:type].nil? || params[:keyword].nil? || (current_user && current_user.user_role == 'admin')
    SearchLog.create(search_type: params[:type], keyword: params[:keyword])
  end
end
