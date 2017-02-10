class AddColumnToCollections < ActiveRecord::Migration
  def up
    add_column :collections, :related_collections, :string

    collections = Collection.all
    collections.each do |collection|
      if collection.show == true
        # 해당 컬렉션과 연관된 키워드 목록 추출
        keyword_ids = CollectionToCollectionKeyword.where(collection_id: collection.id).pluck(:collection_keyword_id)

        # 해당 컬렉션과 연관된 키워드를 공통으로 가지고 있는 모든 컬렉션 목록 추출
        related_collections_ids = []
        keyword_ids.each do |keyword_id|
          keyword_collection_ids = CollectionToCollectionKeyword.where.not(collection_id: collection.id).where(collection_keyword_id: keyword_id).pluck(:collection_id)
          keyword_collection_ids.each do |keyword_collection_id|
            related_collections_ids << keyword_collection_id if Collection.find(keyword_collection_id).show == true
          end
        end

        # 해당 컬렉션과 연관된 키워드를 공통으로 가지고 있는 모든 컬렉션에 대해 우선순위를 나열
        related_collections_ids = related_collections_ids.uniq.sort_by{|x|related_collections_ids.grep(x).size}.reverse

        # 해당 컬렉션의 연관 컬렉션 목록을 DB에 입력
        related_collections_set = ","
        for i in 0...10
          related_collections_set += related_collections_ids[i].to_s + "," unless related_collections_ids[i].blank?
        end
        collection.record_timestamps = false
        collection.update(related_collections: related_collections_set)
        collection.record_timestamps = true
      end
    end
  end

  def down
    remove_column :collections, :related_collections
  end
end
