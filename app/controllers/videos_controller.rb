class VideosController < ApplicationController
  before_action :set_video, only: [:show]

  # GET /videos.json
  def index
    respond_to do |format|
      format.html
      format.json do
        videos = Video.where(show: true)
                      .page(params[:page])
                      .per(Video::VIDEO_PER)
                      .order(id: :desc)
        is_more_load = videos.total_pages > params[:page].to_i
        render json: { videos: videos, is_more_load: is_more_load }
      end
    end
  end

  # GET /videos.json
  def show
    respond_to do |format|
      format.html
      format.json do
        video = @video
        ask = video.ask
        ask.alarm_read(current_user.id) if current_user
        ask = ask.fetch_ask_detail
        render json: {
          video: video,
          ask: ask
        }
      end
    end
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end
end
