class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show]

  # GET /collections
  # GET /collections.json
  def index
    respond_to do |format|
      format.html
      format.json do
        collections = Collection.where(show: true)
                                .order(updated_at: :desc)
                                .page(params[:page])
                                .per(Collection::COLLECTION_PER)
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
        collection = @collection
        collection_to_asks =
          CollectionToAsk.where(collection_id: params[:id])
                         .as_json(include: [:collection, ask: { include: [:user, :left_ask_deal, :right_ask_deal, :votes, :ask_likes] }])

        related_collections = []
        if collection.related_collections && collection.related_collections.length > 1
          related_collections_ids = collection.related_collections
                                              .gsub(/^[,]|[,]$/, '')
                                              .split(',')
          related_collections_ids = related_collections_ids.values_at 0...5 if related_collections_ids.length > 5
          related_collections = Collection.where(show: true)
                                          .where('id IN (?)', related_collections_ids)
                                          .order("FIELD(id,#{related_collections_ids.join(',')})")
        else
          recent_asks = Ask.where(be_completed: false)
                           .page(params[:page])
                           .per(Ask::ASK_PER)
                           .order(id: :desc)

          if current_user
            my_votes = Vote.where(user_id: current_user.id).map(&:ask_id)
            recent_asks = recent_asks.where.not(user_id: current_user.id)
            recent_asks = recent_asks.where('id NOT IN (?)', my_votes) unless my_votes.length.zero?
          end
        end

        render json: {
          collection: collection,
          collection_to_asks: collection_to_asks,
          related_collections: related_collections,
          recent_asks: recent_asks
        }
      end
    end
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end
end
