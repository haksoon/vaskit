class Alram < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'send_user_id'
end
