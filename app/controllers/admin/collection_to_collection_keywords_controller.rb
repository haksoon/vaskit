class Admin::CollectionToCollectionKeywordsController < Admin::HomeController

  # GET /admin/collection_to_collection_keywords.json
  def index
    collection_keywords = CollectionToCollectionKeyword.where(collection_id: params[:collection_id]).as_json(include: [:collection_keyword])
    render :json => {collection_keywords: collection_keywords}
  end

  # POST /admin/collection_to_collection_keywords.json
  def create
    keyword = CollectionKeyword.find_by_keyword(params[:keyword])
    if keyword == nil
      keyword = CollectionKeyword.create(keyword: params[:keyword])
    end

    if CollectionToCollectionKeyword.where(collection_id: params[:collection_id], collection_keyword_id: keyword.id).blank?
      CollectionToCollectionKeyword.create(collection_id: params[:collection_id], collection_keyword_id: keyword.id)
      status = "success"
      collection_keywords = CollectionToCollectionKeyword.where(collection_id: params[:collection_id]).select(:collection_keyword_id).pluck(:collection_keyword_id)
      related_collections_set = []
      collection_keywords.each do |collection_keyword|
        related_collections_of_keyword = CollectionToCollectionKeyword.where.not(collection_id: params[:collection_id]).where(collection_keyword_id: collection_keyword).pluck(:collection_id)
        related_collections_of_keyword.each do |related_collection_of_keyword|
          related_collections_set << related_collection_of_keyword
        end
      end
      related_collections_ids = related_collections_set.uniq.sort_by{|x|related_collections_set.grep(x).size}.reverse
      related_collections = Collection.where("id IN (?)", related_collections_ids).limit(2).as_json(include: [collection_to_asks: {include: [ask: {include: [:left_ask_deal, :right_ask_deal]}]}])
    else
      status = "already_exists"
    end


    render json: { status: status, related_collections: related_collections }
  end

  # DELETE /admin/collection_to_collection_keywords/:id.json
  def destroy

  end

end
