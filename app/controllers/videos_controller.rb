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
        ask = Ask.find(video.ask_id)

        already_like = false
        if current_user
          ask_like = AskLike.where(user_id: current_user.id,
                                   ask_id: video.ask_id)
                            .first
          already_like = ask_like ? true : false
        end

        like_comments = []
        if current_user
          ask_comments = ask.comments.pluck(:id)
          like_comments = CommentLike.where(user_id: current_user.id,
                                            comment_id: ask_comments)
        end

        ask = ask.as_json(include: [:user, :left_ask_deal, :right_ask_deal, :votes, :ask_likes, { comments: { include: :user } }])

        if current_user
          all_alarms = Alarm.where(ask_id: video.ask_id,
                                   user_id: current_user.id,
                                   is_read: false)
          unless all_alarms.blank?
            last_alarm = all_alarms.last
            all_alarms.update_all(is_read: true)
            last_alarm.record_timestamps = false
            last_alarm.update(is_read: true)
            last_alarm.record_timestamps = true
          end
        end

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
