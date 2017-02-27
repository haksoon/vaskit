class Collection < ActiveRecord::Base
  has_attached_file :image,
                    url: '/assets/collections/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/collections/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  has_many :collection_to_asks
  has_many :asks, through: :collection_to_asks
  has_many :collection_to_collection_keywords
  has_many :collection_keywords, through: :collection_to_collection_keywords

  COLLECTION_PER = 3

  validates :name, presence: true
  validates :description, presence: true
  validates :image, presence: true
  # validates :collection_keywords, presence: true
  # validates :asks, presence: true

  before_update :rename_file

  def rename_file
    return if image.blank?
    extension = image_file_name.split('.').last
    return unless %w[jpg jpeg gif png].include?(extension)
    self.image_file_name = "collection.#{extension}"
  end

  def set_related_collections
    # 추출한 키워드를 공통으로 가지고 있는 모든 컬렉션 추출
    keyword_collection_ids = CollectionToCollectionKeyword.where(collection_keyword_id: collection_keywords.map(&:id)).pluck(:collection_id).uniq

    # 공통 키워드를 가진 컬렉션에 대해 연관 컬렉션 목록을 업데이트
    related_collections = Collection.where(id: keyword_collection_ids)
    related_collections.each do |related_collection|
      if related_collection.show
        # 추출한 키워드를 공통으로 가지고 있는 모든 컬렉션 id 추출 및 가중치 배열
        related_collections_ids = []
        related_collection.collection_keywords.each do |related_collection_keyword|
          keyword_collections = CollectionToCollectionKeyword.where.not(collection_id: related_collection.id).where(collection_keyword_id: related_collection_keyword.id)
          keyword_collections.each do |keyword_collection|
            related_collections_ids << keyword_collection.collection_id if keyword_collection.collection.show
          end
        end
        related_collections_ids = related_collections_ids.uniq.sort_by { |x| related_collections_ids.grep(x).size }.reverse[0...10]

        # 해당 컬렉션의 연관 컬렉션 목록을 DB에 입력
        related_collections_set = ",#{related_collections_ids.join(',')},"
      else
        related_collections_set = ','
      end
      related_collection.update(related_collections: related_collections_set)
    end
  end
end
