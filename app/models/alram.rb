class Alram < ActiveRecord::Base
  belongs_to :user, :class_name => 'SendUser', :foreign_key => 'send_user_id'
end
