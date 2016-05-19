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
      if vote
        vote.update(:ask_deal_id => ask_deal_id)
      else
        vote = Vote.create(:ask_id => ask.id, :ask_deal_id => ask_deal_id, :user_id => current_user.id)
      end
    elsif @visitor
      vote = Vote.where(:ask_id => ask.id, :visitor_id => @visitor.id).first
      if vote
        vote.update(:ask_deal_id => ask_deal_id)
      else
        vote = Vote.create(:ask_id => ask.id, :ask_deal_id => ask_deal_id, :visitor_id => @visitor.id)
      end
    end
    ask.reload
    detail_vote_count = ask.detail_vote_count
    ask = ask.as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, {:comments => {:include => :user}}])
    render :json => {:ask => ask, :vote => vote, :detail_vote_count => detail_vote_count}
  end
  
  def destroy
    Vote.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
end
