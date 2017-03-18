class Admin::ReferLinksController < Admin::HomeController
  before_action :set_refer_link, only: [:show, :edit, :update]
  before_action :set_refer_link_options, only: [:new, :create, :edit, :update]

  # GET /admin/refer_links
  def index
    @refer_links = ReferLink.page(params[:page]).per(10).order(id: :desc)
  end

  # GET /admin/refer_links/:id
  def show
  end

  # GET /admin/refer_links/new
  def new
    @refer_link = ReferLink.new
  end

  # POST /admin/refer_links
  def create
    @refer_link = ReferLink.new(refer_link_params)
    unless Time.new(refer_link_params['commerce_ended_at(1i)'], refer_link_params['commerce_ended_at(2i)'], refer_link_params['commerce_ended_at(3i)']) > Time.new(refer_link_params['commerce_started_at(1i)'], refer_link_params['commerce_started_at(2i)'], refer_link_params['commerce_started_at(3i)'])
      flash['error'] = '종료일자는 시작일자보다 이후여야만 합니다'
      render :new and return
    end
    if @refer_link.save
      flash['success'] = "#{@refer_link.id}번 링크를 성공적으로 생성하였습니다"
      redirect_to admin_refer_links_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :new
    end
  end

  # GET /admin/refer_links/:id/edit
  def edit
  end

  # PATCH /admin/refer_links/:id
  def update
    unless Time.new(refer_link_params['commerce_ended_at(1i)'], refer_link_params['commerce_ended_at(2i)'], refer_link_params['commerce_ended_at(3i)']) > Time.new(refer_link_params['commerce_started_at(1i)'], refer_link_params['commerce_started_at(2i)'], refer_link_params['commerce_started_at(3i)'])
      flash['error'] = '종료일자는 시작일자보다 이후여야만 합니다'
      render :edit and return
    end
    if @refer_link.update(refer_link_params)
      flash['success'] = "#{@refer_link.id}번 링크를 성공적으로 수정하였습니다"
      redirect_to admin_refer_links_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :edit
    end
  end

  private

  def set_refer_link
    @refer_link = ReferLink.find(params[:id])
  end

  def set_refer_link_options
    @channels = ReferLink.all.pluck(:channel).uniq
    @commerce_types = ReferLink.all.pluck(:commerce_type).uniq
  end

  def refer_link_params
    params.require(:refer_link).permit(:channel,
                                       :name,
                                       :commerce_type,
                                       :commerce_budget,
                                       :commerce_expense,
                                       :commerce_started_at,
                                       :commerce_ended_at,
                                       :url,
                                       :js,
                                       :connect_to_store)
  end
end
