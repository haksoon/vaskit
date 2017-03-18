class Admin::SearchKeywordsController < Admin::HomeController
  before_action :set_search_keyword, only: [:update, :destroy]

  # GET /admin/search_keywords
  def show
    @search_keywords = SearchKeyword.order(list_order: :asc)
    @new_search_keyword = SearchKeyword.new
    @search_type_label =
      {
        해시태그: 'hash_tag',
        제품명: 'ask_deal',
        브랜드: 'brand',
        통합검색: 'none',
        사용자명: 'user'
      }
    @weekly_search_logs =
      SearchLog.where('created_at > ?', Time.now - (60 * 60 * 24 * 7))
               .group(:keyword, :search_type).select('*, COUNT(*) AS search_count')
               .order('search_count DESC').page(params[:page]).per(10)
    @all_search_logs =
      SearchLog.group(:keyword, :search_type).select('*, COUNT(*) AS search_count')
               .order('search_count DESC').page(params[:page]).per(10)
  end

  # POST /admin/search_keywords
  def create
    if SearchKeyword.all.count >= 10
      flash['error'] = '인기검색어는 최대 열개까지만 등록할 수 있습니다'
    elsif SearchKeyword.find_by(keyword: search_keyword_params[:keyword], search_type: search_keyword_params[:search_type]).nil?
      list_order = SearchKeyword.all.count + 1
      search_keyword = SearchKeyword.create(keyword: search_keyword_params[:keyword], search_type: search_keyword_params[:search_type], list_order: list_order)
      flash['success'] = "#{search_keyword.list_order}번/#{search_keyword.keyword}/#{search_keyword.search_type} 인기검색어를 등록했습니다"
    else
      flash['warning'] = '이미 등록된 인기검색어입니다'
    end
    redirect_to admin_search_keywords_path
  end

  # PATCH /admin/search_keywords
  def update
    if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(params[:is_up])
      list_order = @search_keyword.list_order - 1
      if list_order.zero?
        flash['warning'] = '첫번째 항목입니다'
      else
        SearchKeyword.find_by(list_order: list_order).increment(:list_order, 1).save!
        @search_keyword.decrement(:list_order, 1).save!
      end
    else
      list_order = @search_keyword.list_order + 1
      if list_order > SearchKeyword.all.count
        flash['warning'] = '마지막 항목입니다'
      else
        SearchKeyword.find_by(list_order: list_order).decrement(:list_order, 1).save!
        @search_keyword.increment(:list_order, 1).save!
      end
    end
    redirect_to admin_search_keywords_path
  end

  # DELETE /admin/search_keywords
  def destroy
    if SearchKeyword.all.count <= 5
      flash['error'] = '인기검색어는 최소 다섯개 이상을 유지해주세요'
      redirect_to admin_search_keywords_path
    else
      @search_keyword.destroy
      SearchKeyword.where('list_order > ?', @search_keyword.list_order).each do |search_keyword|
        search_keyword.decrement(:list_order, 1).save!
      end
      flash['warning'] = "#{@search_keyword.list_order}번 인기검색어를 제거하였습니다"
      redirect_to admin_search_keywords_path
    end
  end

  private

  def set_search_keyword
    @search_keyword = SearchKeyword.find(params[:id])
  end

  def search_keyword_params
    params.require(:search_keyword).permit(:keyword,
                                           :search_type)
  end
end
