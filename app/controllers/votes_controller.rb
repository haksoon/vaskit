# coding : utf-8
class VotesController < ApplicationController

  # POST /votes.json
  def create
    ask = Ask.find_by_id(params[:ask_id])
    ask_deal_id = params[:is_left] == "true" ? ask.left_ask_deal_id : ask.right_ask_deal_id

    if current_user
      vote = Vote.find_by(ask_id: ask.id, user_id: current_user.id)
      if vote
        vote.update(ask_deal_id: ask_deal_id)
      else
        vote = Vote.create(ask_id: ask.id, ask_deal_id: ask_deal_id, user_id: current_user.id)
      end
    end

    ask = ask.as_json(include: [:left_ask_deal, :right_ask_deal])

    render json: {ask: ask, vote: vote}
  end

  # DELETE /votes/destroy.json
  def destroy
    vote = Vote.find(params[:id])
    vote.destroy unless vote.nil? && vote.user_id != current_user.id
    render json: {}
  end

end
