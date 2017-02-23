class Admin::CollectionKeywordsController < Admin::HomeController
  # GET /admin/collection_keywords.json
  def index
    keyword = params[:keyword].gsub(/\s/, '')
    @new_keyword = keyword if CollectionKeyword.where(keyword: keyword).blank?
    @keywords = CollectionKeyword.where("keyword LIKE ?", "%#{keyword}%").order(refer_count: :desc)
  end

  # POST /admin/collection_keywords
  def create
    keyword = params[:keyword].gsub(/\s/, '')
    @keyword = CollectionKeyword.where(keyword: keyword).first
    if @keyword.nil?
      @keyword = CollectionKeyword.create(keyword: keyword)
    end
  end
end
