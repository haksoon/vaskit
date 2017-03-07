class Category < ActiveRecord::Base
  has_many :asks
  has_many :user_categories
end
