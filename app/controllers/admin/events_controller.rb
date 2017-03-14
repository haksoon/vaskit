class Admin::EventsController < Admin::HomeController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /admin/events
  def index
    @schedules =
      Event.where('started_at >= ?', Time.now)
           .order(started_at: :asc)
    @ongoings =
      Event.where('started_at < ? AND ended_at > ?', Time.now, Time.now)
           .order(ended_at: :desc)
    @events =
      Event.where('ended_at <= ?', Time.now)
           .order(id: :desc)
           .page(params[:page]).per(10)
  end

  # GET /admin/events/:id
  def show
  end

  # GET /admin/events/new
  def new
    @event = Event.new
  end

  # POST /admin/events
  def create
    @event = Event.new(event_params)
    if @event.save
      @event.ask.update(event_id: @event.id)
      flash['success'] = "<#{@event.title}> 이벤트를 성공적으로 생성하였습니다"
      redirect_to admin_events_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :new
    end
  end

  # GET /admin/events/:id/edit
  def edit
  end

  # PATCH /admin/events/:id
  def update
    if @event.update(event_params)
      flash['success'] = "<#{@event.title}> 이벤트를 성공적으로 수정하였습니다"
      redirect_to admin_events_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :edit
    end
  end

  # DELETE /admin/events/:id
  def destroy
    @event.destroy
    @event.ask.update(event_id: nil)
    flash['warning'] = "<#{@event.title}> 이벤트를 삭제하였습니다"
    redirect_to :back
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title,
                                  :description,
                                  :ask_id,
                                  :started_at,
                                  :ended_at,
                                  :image)
  end
end
