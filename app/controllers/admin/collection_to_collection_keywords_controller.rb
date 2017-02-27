class Admin::CollectionToCollectionKeywordsController < Admin::HomeController
  # GET /admin/collection_to_collection_keywords
  def index
    return if params[:keyword_ids].blank?
    keyword_collections = CollectionToCollectionKeyword.where(collection_keyword_id: params[:keyword_ids].split(" "))
    keyword_collections = keyword_collections.where.not(collection_id: params[:collection_id]) unless params[:collection_id].blank?
    keyword_collections = keyword_collections.group(:collection_id).order("collection_count DESC").select(:collection_id, "count(collection_id) AS collection_count")
    related_collections_ids = keyword_collections.map(&:collection_id)
    @related_collections =
      if related_collections_ids.blank?
        []
      else
        Collection.where(show: true, id: related_collections_ids)
                  .order("FIELD(id,#{related_collections_ids.join(',')})")
      end
  end
end
