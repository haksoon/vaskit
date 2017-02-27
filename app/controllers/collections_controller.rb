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
        keyword_ids = CollectionToCollectionKeyword.where(collection_id: @collection.id).pluck(:collection_keyword_id)
        keyword_collections = CollectionToCollectionKeyword.where(collection_keyword_id: keyword_ids).where.not(collection_id: @collection.id)
        related_collections_ids = keyword_collections.group(:collection_id).order("collection_count DESC").select(:collection_id, "count(collection_id) AS collection_count").map(&:collection_id)
        if !related_collections_ids.empty?
          @related_collections = Collection.where(show: true, id: related_collections_ids)
                                           .order("FIELD(id,#{related_collections_ids.join(',')})")
                                           .limit(5)
        else
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
          asks: @collection.asks.as_json(include: [:user, :left_ask_deal, :right_ask_deal, :votes, :ask_likes]),
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
