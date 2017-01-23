class Admin::VideosController < Admin::HomeController

  # GET /admin/videos
  def index
    @videos = Video.all.order("id desc")
    render :layout => "layout_admin"
  end

  # POST /admin/videos.json
  def create
    video = Video.create(:ask_id => params[:ask_id], :title => params[:title], :url => params[:url])
    render :json => {:status => "success"}
  end

end
