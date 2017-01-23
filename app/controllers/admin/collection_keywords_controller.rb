class Admin::CollectionKeywordsController < Admin::HomeController

  # GET /admin/collection_keywords.json
  def index
    keyword = params[:keyword]
    collection_keywords = CollectionKeyword.where("keyword LIKE ?", "%#{keyword}%").order(refer_count: :desc)
    render json: { collection_keywords: collection_keywords }
  end

end
