class ShareLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :ask
  belongs_to :collection
  belongs_to :video
end
