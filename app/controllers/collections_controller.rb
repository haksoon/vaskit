class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show]

  # GET /collections
  # GET /collections.json
  def index
    respond_to do |format|
      format.html
      format.json {
        collections = Collection.where(show: true)
                                .order(updated_at: :desc).page(params[:page]).per(Collection::COLLECTION_PER)
        render json: {collections: collections}
      }
    end
  end

  # GET /collections/:id
  # GET /collections/:id.json
  def show
    respond_to do |format|
      format.html
      format.json {
        collection = @collection
        collection_to_asks = CollectionToAsk.where(collection_id: params[:id])
                                            .as_json(include: [:collection, ask: {include: [:user, :left_ask_deal, :right_ask_deal, :votes, :ask_likes]}])

        related_collections = []
        if collection.related_collections && collection.related_collections.length > 1
          related_collections_ids = collection.related_collections.gsub(/^[,]|[,]$/, '').split(",")
          related_collections_ids = related_collections_ids.values_at 0...5 if related_collections_ids.length > 5
          related_collections = []
          related_collections_ids.each.with_index(1) { |id, i| related_collections << Collection.find_by(id: id, show: true) }
        else
          if current_user
            my_votes = Vote.where(user_id: current_user.id).map(&:ask_id)
            if my_votes.length == 0 # 첫 회원가입의 경우 my_votes가 null이어서 아무것도 노출이 안됨
              recent_asks = Ask.where(be_completed: false)
                            .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
            else
              recent_asks = Ask.where(be_completed: false).where("id NOT IN (?) AND user_id NOT IN (?)", my_votes, current_user.id)
                            .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
            end
          else
              recent_asks = Ask.where(be_completed: false)
                            .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
          end
        end

        render json: {collection: collection, collection_to_asks: collection_to_asks, related_collections: related_collections, recent_asks: recent_asks}
      }
    end
  end

  private
  def set_collection
    @collection = Collection.find(params[:id])
  end

end
