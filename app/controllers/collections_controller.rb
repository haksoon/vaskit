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
        is_more_load = collections.total_pages > params[:page].to_i
        render json: { collections: collections, is_more_load: is_more_load }
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
        related_collections = collection.find_related_collections.limit(5)
        if related_collections.blank?
          recent_asks = Ask.page(params[:page])
                           .per(Ask::ASK_PER)
                           .order(id: :desc)

          if current_user
            my_votes = Vote.where(user_id: current_user.id).map(&:ask_id)
            recent_asks = recent_asks.where.not(user_id: current_user.id)
            recent_asks = recent_asks.where.not(id: my_votes) unless my_votes.empty?
          end
        end

        asks = collection.asks
                         .as_json(include: [{ user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } },
                                            { left_ask_deal: { include: [{ recent_comment: { include: [user: { only: [:id, :string_id] }] } } ] } },
                                            { right_ask_deal: { include: [{ recent_comment: { include: [user: { only: [:id, :string_id] }] } } ] } },
                                            :votes,
                                            { ask_likes: { include: { user: { only: [:id, :string_id] } } } },
                                            :ask_complete,
                                            :event])

        render json: {
          collection: collection,
          asks: asks,
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
