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
        render json: { videos: videos }
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

        already_like = false
        like_comments = []
        if current_user
          already_like = ask.fetch_ask_likes(current_user.id)
          like_comments = ask.fetch_comment_likes(current_user.id)
          ask.alarm_read(current_user.id)
        end

        ask = ask.fetch_ask_detail

        render json: {
          video: video,
          ask: ask,
          already_like: already_like,
          like_comments: like_comments
        }
      end
    end
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end
end
