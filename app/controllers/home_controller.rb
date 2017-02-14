class HomeController < ApplicationController
  # GET /
  def index
    @event_ask = Ask.find(70).as_json(include: [:user, :left_ask_deal, :right_ask_deal, :votes, :hash_tags, { comments: { include: :user } }])
  end

  # GET /landing
  def landing
  end
end
