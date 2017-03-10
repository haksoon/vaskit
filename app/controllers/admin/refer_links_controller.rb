class Admin::ReferLinksController < Admin::HomeController
  before_action :set_refer_link, only: [:show, :edit, :update, :destroy]

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
