class CollectionKeyword < ActiveRecord::Base
  has_many :collections, through: :collection_to_collection_keyword
end
