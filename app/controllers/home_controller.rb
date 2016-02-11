# coding : utf-8
class HomeController < ApplicationController
  
  def index
    case params[:type]
      when "user"
        @asks = Ask.where(:user_id => params[:keyword]).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal])
      when "hash_tag"
      when "ask_deal"
        ask_deal = AskDeal.find_by_id(params[:keyword])
        @asks = Ask.where("left_ask_deal_id = ? OR right_ask_deal_id = ?", ask_deal.id, ask_deal.id).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal]) if ask_deal
      when "brand"
        ask_deals = AskDeal.where("brand like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where("left_ask_deal_id in (?) OR right_ask_deal_id = (?)", ask_deals.map(&:id), ask_deals.map(&:id)).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal]) unless ask_deals.blank?
      else
        @asks = Ask.all.order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal])
    end
    
    
    if current_user
      @my_votes = Vote.where(:user_id => current_user.id)
    elsif @visitor
      @my_votes = Vote.where(:visitor_id => @visitor.id)  
    end
    
  end
end
