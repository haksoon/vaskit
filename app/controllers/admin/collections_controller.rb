class Admin::CollectionsController < Admin::HomeController

  # GET /admin/collections
  def index
    @collections = Collection.all.order(updated_at: :desc)
    render :layout => "layout_admin"
  end

  # GET /admin/collections/id
  def show
    @collection = Collection.find(params[:id])
    render :layout => "layout_admin"
  end

  # POST /admin/collections.json
  def create
    Collection.create(name: params[:name], description: params[:desc])
    render :json => {}
  end

  # PUT /admin/collections/:id.json
  def update
    collection = Collection.find(params[:id])
    if collection.show
      collection.update(show: false)
      status = "off"
    else
      collection.update(show: true)
      status = "on"
    end
    render :json => {status: status}
  end

  # POST /admin/collections/:id/image_upload.json
  def image_upload
    image = params[:File]
    collection = Collection.find(params[:id])
    collection.update(image: image)
    image_url = collection.image.url(:original)
    render json: { image_url: image_url }
  end

end
