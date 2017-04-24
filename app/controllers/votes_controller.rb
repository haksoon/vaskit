class VotesController < ApplicationController
  # POST /votes.json
  def create
    ask = Ask.find_by_id(params[:ask_id])
    ask_deal_id = params[:is_left] == 'true' ? ask.left_ask_deal_id : ask.right_ask_deal_id

    if current_user
      vote = Vote.find_by(ask_id: ask.id, user_id: current_user.id)
      if vote
        vote.update(ask_deal_id: ask_deal_id)
      else
        vote = Vote.create(ask_id: ask.id,
                           ask_deal_id: ask_deal_id,
                           user_id: current_user.id)
        UserActivityScore.update_by(vote)
      end
    end

    left_vote_count = ask.left_ask_deal.vote_count
    right_vote_count = ask.right_ask_deal.vote_count

    render json: { left_vote_count: left_vote_count, right_vote_count: right_vote_count, vote: vote }
  end

  # DELETE /votes/:id.json
  def destroy
    vote = Vote.find(params[:id])
    unless vote.nil? && vote.user_id != current_user.id
      vote.update(is_deleted: true)
      UserActivityScore.update_by(vote)
    end
    render json: {}
  end
end
