# coding : utf-8
class VotesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  def create
    ask_deal_id = params[:ask_deal_id]
    ask = Ask.find_by_id(params[:ask_id])

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
    ask = ask.as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, {:comments => {:include => :user}}])
    render :json => { :ask => ask, :vote => vote }
  end

  def destroy
    Vote.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

  def vote_cancle
    if current_user
      vote = Vote.find_by(:ask_id => params[:ask_id], :user_id => current_user.id)
    else
      vote = Vote.find_by(:ask_id => params[:ask_id], :visitor_id => @visitor.id)
    end
    vote.destroy unless vote.nil?
    render :json => {}
  end
end
