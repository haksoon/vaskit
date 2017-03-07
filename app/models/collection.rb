class Collection < ActiveRecord::Base
  COLLECTION_PER = 3

  has_many :collection_to_asks
  has_many :asks, through: :collection_to_asks
  has_many :collection_to_collection_keywords
  has_many :collection_keywords, through: :collection_to_collection_keywords
  has_many :share_logs

  has_attached_file :image,
                    url: '/assets/collections/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/collections/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

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

  def find_related_collections
    keyword_ids = CollectionToCollectionKeyword.where(collection_id: id)
                                               .pluck(:collection_keyword_id)
    keyword_collections = CollectionToCollectionKeyword.where(collection_keyword_id: keyword_ids)
                                                       .where.not(collection_id: id)
    related_collections_ids = keyword_collections.group(:collection_id)
                                                 .order('collection_count DESC')
                                                 .select(:collection_id, 'count(collection_id) AS collection_count')
                                                 .map(&:collection_id)
    if related_collections_ids.empty?
      Collection.none
    else
      Collection.where(show: true, id: related_collections_ids)
                .order("FIELD(id,#{related_collections_ids.join(',')})")
    end
  end
end
