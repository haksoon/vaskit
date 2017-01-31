# coding : utf-8
class VideosController < ApplicationController

  # GET /videos.json
  def index
    respond_to do |format|
      format.html
      format.json {
        videos = Video.page(params[:page]).per(Video::VIDEO_PER).order(updated_at: :desc)
        render json: {videos: videos}
      }
    end
  end

end
