# coding : utf-8
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
        # render json: {collection: collection, collection_to_asks: collection_to_asks}


        # 보정 필요
        collection_keywords = CollectionToCollectionKeyword.where(collection_id: params[:id]).select(:collection_keyword_id).pluck(:collection_keyword_id)
        related_collections_set = []
        collection_keywords.each do |keyword|
          related_collections_of_keyword = CollectionToCollectionKeyword.where.not(collection_id: params[:id]).where(collection_keyword_id: keyword).pluck(:collection_id)
          related_collections_of_keyword.each do |related_collection_of_keyword|
            related_collections_set << related_collection_of_keyword
          end
        end
        related_collections_ids = related_collections_set.uniq.sort_by{|x|related_collections_set.grep(x).size}.reverse
        related_collections = Collection.where(show: true).where("id IN (?)", related_collections_ids).as_json(include: [collection_to_asks: {include: [ask: {include: [:left_ask_deal, :right_ask_deal]}]}])

        if related_collections.count == 0
          if current_user
            my_votes = Vote.where(user_id: current_user.id)
            recent_asks = Ask.where(be_completed: false).where("id NOT IN (?) AND user_id NOT IN (?)", my_votes.map(&:ask_id), current_user.id)
                             .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                             .as_json(include: [:left_ask_deal, :right_ask_deal])
          else
            recent_asks = Ask.where(be_completed: false)
                             .page(params[:page]).per(Ask::ASK_PER).order(id: :desc)
                             .as_json(include: [:left_ask_deal, :right_ask_deal])
          end
        end

        render json: {collection: collection, collection_to_asks: collection_to_asks, related_collections: related_collections, recent_asks: recent_asks}
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

end
