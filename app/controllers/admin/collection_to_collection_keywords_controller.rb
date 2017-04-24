class Admin::CollectionToCollectionKeywordsController < Admin::HomeController
  # GET /admin/collection_to_collection_keywords
  def index
    return if params[:keyword_ids].blank?
    keyword_ids = params[:keyword_ids].split(" ")

    keyword_collections = CollectionToCollectionKeyword.where(collection_keyword_id: keyword_ids)
    keyword_collections = keyword_collections.where.not(collection_id: params[:collection_id]) unless params[:collection_id].blank?

    related_collections_ids = keyword_collections.group(:collection_id)
                                                 .order('collection_count DESC')
                                                 .select(:collection_id, 'count(collection_id) AS collection_count')
                                                 .map(&:collection_id)
    @related_collections =
      if related_collections_ids.blank?
        Collection.none
      else
        Collection.where(id: related_collections_ids)
                  .order("FIELD(id,#{related_collections_ids.join(',')})")
      end
  end
end
