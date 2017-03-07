class CollectionToAsk < ActiveRecord::Base
  default_scope { order(seq: :asc) }

  belongs_to :collection
  belongs_to :ask
end
