class Admin::VideosController < Admin::HomeController

  # GET /admin/videos
  def index
    @videos = Video.all.order(id: :desc)
    render layout: "layout_admin"
  end

  # POST /admin/videos.json
  def create
    video = Video.create(ask_id: params[:ask_id], title: params[:title], url: params[:url], image: params[:File])

    if params[:push_checked] == "true"
      payload = {
        msg: params[:push_text],
        type: "true",
        count: nil,
        id: params[:ask_id].to_s,
        link: CONFIG["host"] + "/videos",
        js: "go_url('video_asks')",
      }
      push_send_to_all("video", payload)
    end

    render json: {}
  end

end
