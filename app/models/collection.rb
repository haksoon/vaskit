class Collection < ActiveRecord::Base
  has_attached_file :image,
                    url: '/assets/collections/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/collections/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  has_many :collection_to_asks
  has_many :collection_to_collection_keywords

  COLLECTION_PER = 3

  before_update :rename_file

  def rename_file
    return if image.blank?
    extension = image_file_name.split('.').last
    return unless %w[jpg jpeg gif png].include?(extension)
    self.image_file_name = "collection.#{extension}"
  end

  def set_related_collections
    # 해당 컬렉션과 연관된 키워드 목록 추출
    keywords = CollectionToCollectionKeyword.where(collection_id: id)

    # 추출한 키워드를 공통으로 가지고 있는 모든 컬렉션 추출
    keyword_collection_ids = CollectionToCollectionKeyword.where(collection_keyword_id: keywords.map(&:collection_keyword_id)).pluck(:collection_id).uniq

    # 모든 컬렉션에 대해 연관 컬렉션 목록을 업데이트
    related_collections = Collection.where(id: keyword_collection_ids)
    related_collections.each do |related_collection|
      if related_collection.show
        # 해당 컬렉션과 연관된 키워드 목록 추출
        related_collection_keywords = CollectionToCollectionKeyword.where(collection_id: related_collection.id)

        # 추출한 키워드를 공통으로 가지고 있는 모든 컬렉션 id 추출 및 가중치 배열
        related_collections_ids = []
        related_collection_keywords.each do |related_collection_keyword|
          keyword_collections = CollectionToCollectionKeyword.where.not(collection_id: related_collection.id).where(collection_keyword_id: related_collection_keyword.collection_keyword_id)
          keyword_collections.each do |keyword_collection|
            related_collections_ids << keyword_collection.collection_id if keyword_collection.collection.show
          end
        end
        related_collections_ids = related_collections_ids.uniq.sort_by{ |x| related_collections_ids.grep(x).size }.reverse

        # 해당 컬렉션의 연관 컬렉션 목록을 DB에 입력
        related_collections_set = ','
        for i in 0...10
          related_collections_set += related_collections_ids[i].to_s + ',' unless related_collections_ids[i].blank?
        end
      else
        related_collections_set = ','
      end
      related_collection.record_timestamps = false
      related_collection.update(related_collections: related_collections_set)
      related_collection.record_timestamps = true
    end
  end
end
