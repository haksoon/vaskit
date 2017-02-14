class CollectionToCollectionKeyword < ActiveRecord::Base
  belongs_to :collection
  belongs_to :collection_keyword

  after_create :reload_refer_count
  after_destroy :reload_refer_count

  def reload_refer_count
    refer_count = CollectionToCollectionKeyword.where(collection_keyword_id: collection_keyword_id).count
    collection_keyword = CollectionKeyword.find(collection_keyword_id)
    collection_keyword.update(refer_count: refer_count)
  end
end
