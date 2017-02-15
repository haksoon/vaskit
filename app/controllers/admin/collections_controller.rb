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

    collection.set_related_collections

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
end
