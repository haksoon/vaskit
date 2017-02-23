class Admin::CollectionToCollectionKeywordsController < Admin::HomeController
  # GET /admin/collection_to_collection_keywords
  def index
    return if params[:keyword_ids].blank?
    related_collections_ids = []
    keyword_collections =
      if params[:collection_id].blank?
        CollectionToCollectionKeyword.where(collection_keyword_id: params[:keyword_ids].split(" "))
      else
        CollectionToCollectionKeyword.where.not(collection_id: params[:collection_id]).where(collection_keyword_id: params[:keyword_ids].split(" "))
      end
    keyword_collections.each do |keyword_collection|
      related_collections_ids << keyword_collection.collection_id if keyword_collection.collection.show
    end
    related_collections_ids = related_collections_ids.uniq.sort_by { |x| related_collections_ids.grep(x).size }.reverse[0...10]

    @related_collections = Collection.where(id: related_collections_ids)
  end
end
