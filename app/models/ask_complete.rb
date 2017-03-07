class AskComplete < ActiveRecord::Base
  belongs_to :ask
  belongs_to :user
  belongs_to :ask_deal
end
