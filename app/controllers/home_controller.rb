# coding : utf-8
class HomeController < ApplicationController
  
  def index
    @asks = Ask.all.order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal])
    
    if current_user
      @my_votes = Vote.where(:user_id => current_user.id)
    elsif @visitor
      @my_votes = Vote.where(:visitor_id => @visitor.id)  
    end
    
  end
end
