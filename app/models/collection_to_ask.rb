class CollectionToAsk < ActiveRecord::Base
  belongs_to :collection
  belongs_to :ask

  default_scope { order(seq: :asc) }
end
