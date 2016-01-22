# coding : utf-8
class HomeController < ApplicationController
  
  def index
    @asks = Ask.all.order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal])
    
  end
end
