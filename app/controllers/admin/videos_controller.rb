class Admin::VideosController < Admin::HomeController
  before_action :set_video, only: [:show, :edit, :update, :destroy]
  before_action :load_facebook_video, only: [:new, :create, :edit, :update]

  # GET /admin/videos
  def index
    @videos = Video.page(params[:page]).per(10).order(id: :desc)
  end

  # GET /admin/videos/:id
  def show
  end

  # GET /admin/videos/new
  def new
    @video = Video.new
  end

  # POST /admin/videos
  def create
    @video = Video.new(video_params)
    if @video.save
      flash['success'] = "#{@video.id}번 비교영상을 성공적으로 생성하였습니다"
      redirect_to admin_videos_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :new
    end
  end

  # GET /admin/videos/:id/edit
  def edit
  end

  # PATCH /admin/videos/:id
  def update
    if @video.update(video_params)
      flash['success'] = "#{@video.id}번 비교영상을 성공적으로 수정하였습니다"
      redirect_to admin_videos_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :edit
    end
  end

  # DELETE /admin/videos/:id
  def destroy
    @video.toggle(:show)
    if @video.save
      if @video.show
        flash['success'] = "#{@video.id}번 비교영상을 성공적으로 발행하였습니다 <a href='#{video_path(@video.id)}' target='_blank' class='alert-link'>링크</a>"
      else
        flash['warning'] = "#{@video.id}번 비교영상을 발행 취소하였습니다"
      end
    else
      flash['error'] = "#{@video.id}번 비교영상 발행 전 필수 입력값을 모두 입력해주세요"
    end
    redirect_to :back
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end

  def load_facebook_video
    auth = Koala::Facebook::OAuth.new(Facebook::APP_ID,
                                      Facebook::SECRET)
    access_token = auth.get_app_access_token
    api = Koala::Facebook::API.new(access_token)
    graph = api.get_object("#{Facebook::PAGE_ID}/?fields=videos")
    @facebook_video_list = graph['videos']['data']
  end

  def video_params
    params.require(:video).permit(:title,
                                  :description,
                                  :image,
                                  :fb_id,
                                  :yt_id,
                                  :ask_id)
  end
end
