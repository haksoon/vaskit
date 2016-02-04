# coding : utf-8
class VotesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def create
    ask_deal_id = params[:ask_deal_id]
    if ActiveRecord::Type::Boolean.new.type_cast_from_database(params[:is_left])
      ask = Ask.find_by_left_ask_deal_id(ask_deal_id)
      
    else
      ask = Ask.find_by_right_ask_deal_id(ask_deal_id)  
    end
    
    if current_user
      vote = Vote.where(:ask_id => ask.id, :user_id => current_user.id).first
      vote = Vote.create(:ask_id => ask.id, :ask_deal_id => ask_deal_id, :user_id => current_user.id) if vote.blank? 
    elsif @visitor
      vote = Vote.where(:ask_id => ask.id, :visitor_id => @visitor.id).first
      vote = Vote.create(:ask_id => ask.id, :ask_deal_id => ask_deal_id, :visitor_id => @visitor.id) if vote.blank? 
    end
    ask.reload
    ask = ask.as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, {:comments => {:include => :user}}])
    render :json => {:ask => ask, :vote => vote}
  end
  
  def destroy
    Vote.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
