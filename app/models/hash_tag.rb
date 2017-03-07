class HashTag < ActiveRecord::Base
  belongs_to :user
  belongs_to :ask
  belongs_to :comment
end
