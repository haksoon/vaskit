# coding : utf-8
class AlramsController < ApplicationController
  
  def index
    @alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(15)
  end
  
  
  def all_read
    Alram.where(:user_id => current_user.id, :is_read => false).each do |alram|
      alram.update(:is_read => true)
    end
    redirect_to "/alrams"
  end
  
end
