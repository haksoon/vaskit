class ReferLink < ActiveRecord::Base
  has_many :user_visits

  validates :channel, presence: true
  validates :name, presence: true
  validates :commerce_type, presence: true
  validates :url, presence: true
end
