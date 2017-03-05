class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show]

  # GET /collections
  # GET /collections.json
  def index
    respond_to do |format|
      format.html
      format.json do
        collections = Collection.where(show: true)
                                .page(params[:page])
                                .per(Collection::COLLECTION_PER)
                                .order(id: :desc)
        render json: { collections: collections }
      end
    end
  end

  # GET /collections/:id
  # GET /collections/:id.json
  def show
    respond_to do |format|
      format.html
      format.json do
        @related_collections = @collection.find_related_collections.limit(5)
        if @related_collections.blank?
          @recent_asks = Ask.where(be_completed: false)
                            .page(params[:page])
                            .per(Ask::ASK_PER)
                            .order(id: :desc)

          if current_user
            my_votes = Vote.where(user_id: current_user.id).map(&:ask_id)
            @recent_asks = @recent_asks.where.not(user_id: current_user.id)
            @recent_asks = @recent_asks.where.not(id: my_votes) unless my_votes.empty?
          end
        end

        render json: {
          collection: @collection,
          asks: @collection.asks.as_json(include: [:user, :left_ask_deal, :right_ask_deal, :votes, :ask_likes, :ask_complete]),
          related_collections: @related_collections,
          recent_asks: @recent_asks
        }
      end
    end
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end
end
