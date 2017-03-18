class SearchKeyword < ActiveRecord::Base
  validates :keyword, presence: true
  validates :search_type, presence: true
  validates :list_order, presence: true
end
