class Admin::CollectionsController < Admin::HomeController
  before_action :set_collection, only: [:show, :update, :image_upload]

  # GET /admin/collections
  def index
    @collections = Collection.all.order(updated_at: :desc)
    render layout: "layout_admin"
  end

  # GET /admin/collections/id
  def show
    render layout: "layout_admin"
  end

  # POST /admin/collections.json
  def create
    Collection.create(name: params[:name], description: params[:desc])
    render json: {}
  end

  # PUT /admin/collections/:id.json
  def update
    collection = @collection

    if collection.show
      collection.update(show: false, related_collections: ",")
      status = "off"
    else
      collection.update(show: true)
      status = "on"
    end

    if params[:push_checked] == "true"
      payload = {
        msg: params[:push_text],
        type: "true",
        count: nil,
        id: params[:id].to_s,
        link: CONFIG["host"] + "/collections/" + params[:id].to_s,
        js: "go_url('collection', " + params[:id].to_s + ")",
      }
      push_send_to_all("collection", payload)
    end

    set_related_collections(collection)

    render json: {status: status}
  end

  # POST /admin/collections/:id/image_upload.json
  def image_upload
    image = params[:File]
    collection = @collection
    collection.record_timestamps = false
    collection.update(image: image)
    collection.record_timestamps = true
    image_url = collection.image.url(:original)
    render json: { image_url: image_url }
  end


  private
  def set_collection
    @collection = Collection.find(params[:id])
  end

  def set_related_collections(collection)
    # 해당 컬렉션과 연관된 키워드 목록 추출
    keywords = CollectionToCollectionKeyword.where(collection_id: collection.id)

    # 추출한 키워드를 공통으로 가지고 있는 모든 컬렉션 추출
    keyword_collection_ids = CollectionToCollectionKeyword.where(collection_keyword_id: keywords.map(&:collection_keyword_id)).pluck(:collection_id).uniq

    # 모든 컬렉션에 대해 연관 컬렉션 목록을 업데이트
    related_collections = Collection.where(id: keyword_collection_ids)
    related_collections.each do |related_collection|
      if related_collection.show
        # 해당 컬렉션과 연관된 키워드 목록 추출
        related_collection_keywords = CollectionToCollectionKeyword.where(collection_id: related_collection.id)

        # 추출한 키워드를 공통으로 가지고 있는 모든 컬렉션 id 추출 및 가중치 배열
        related_collections_ids = []
        related_collection_keywords.each do |related_collection_keyword|
          keyword_collections = CollectionToCollectionKeyword.where.not(collection_id: related_collection.id).where(collection_keyword_id: related_collection_keyword.collection_keyword_id)
          keyword_collections.each do |keyword_collection|
            related_collections_ids << keyword_collection.collection_id if keyword_collection.collection.show
          end
        end
        related_collections_ids = related_collections_ids.uniq.sort_by{ |x| related_collections_ids.grep(x).size }.reverse

        # 해당 컬렉션의 연관 컬렉션 목록을 DB에 입력
        related_collections_set = ","
        for i in 0...10
          related_collections_set += related_collections_ids[i].to_s + "," unless related_collections_ids[i].blank?
        end
      else
        related_collections_set = ","
      end
      related_collection.record_timestamps = false
      related_collection.update(related_collections: related_collections_set)
      related_collection.record_timestamps = true
    end
  end
end
