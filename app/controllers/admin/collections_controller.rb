class Admin::CollectionsController < Admin::HomeController
  before_action :set_collection, only: [:show, :edit, :update, :destroy]

  # GET /admin/collections
  def index
    @collections = Collection.where.not(published_at: nil)
                             .order(published_at: :desc)
                             .page(params[:page])
                             .per(10)
    @unpublished_collections = Collection.where(published_at: nil)
                                         .order(id: :desc)
  end

  # GET /admin/collections/:id
  def show
    @related_collections = @collection.fetch_related_collections
  end

  # GET /admin/collections/new
  def new
    @collection = Collection.new
  end

  # POST /admin/collections
  def create
    @collection = Collection.new(collection_params)
    if @collection.save
      generate_collection_asks(params[:collection][:asks])
      generate_collection_keywords(params[:collection][:collection_keywords])
      flash['success'] = "#{@collection.id}번 컬렉션을 성공적으로 생성하였습니다"
      redirect_to admin_collections_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :new
    end
  end

  # GET /admin/collections/:id/edit
  def edit
    return unless @collection.published_at
    flash['warning'] = '이미 발행한 컬렉션을 수정할 경우 다른 연관컬렉션에 영향을 미칠 수 있습니다'
  end

  # PATCH /admin/collections/:id
  def update
    if @collection.update(collection_params)
      generate_collection_asks(params[:collection][:asks])
      generate_collection_keywords(params[:collection][:collection_keywords])
      flash['success'] = "#{@collection.id}번 컬렉션을 성공적으로 수정하였습니다"
      redirect_to admin_collections_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :edit
    end
  end

  # DELETE /admin/collections/:id
  def destroy
    min_keywords = 3
    min_contents = 5

    if !@collection.published_at && @collection.collection_keywords.count < min_keywords
      flash['error'] = "컬렉션을 발행하려면 키워드를 최소 #{min_keywords}개 이상 포함해주세요"
      redirect_to :back and return
    elsif !@collection.published_at && @collection.asks.count < min_contents
      flash['error'] = "컬렉션을 발행하려면 컨텐츠를 최소 #{min_contents}개 이상 포함해주세요"
      redirect_to :back and return
    end

    @collection.published_at = @collection.published_at.nil? ? Time.now : nil
    if @collection.save
      unless @collection.published_at.nil?
        flash['success'] = "#{@collection.id}번 컬렉션을 성공적으로 발행하였습니다 <a href='#{collection_path(@collection.id)}' target='_blank' class='alert-link'>링크</a>"
      else
        flash['warning'] = "#{@collection.id}번 컬렉션을 발행 취소하였습니다"
      end
    else
      flash['error'] = "#{@collection.id}번 컬렉션 발행 전 필수 입력값을 모두 입력해주세요"
    end
    redirect_to :back
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name,
                                       :description,
                                       :image)
  end

  def generate_collection_asks(ask_ids)
    CollectionToAsk.destroy_all(collection_id: @collection.id)
    ask_ids.split(' ').each_with_index do |ask_id, index|
      CollectionToAsk.create(collection_id: @collection.id,
                             ask_id: ask_id,
                             seq: index)
    end
  end

  def generate_collection_keywords(collection_keyword_ids)
    CollectionToCollectionKeyword.destroy_all(collection_id: @collection.id)
    collection_keyword_ids.split(' ').each do |collection_keyword_id|
      CollectionToCollectionKeyword.create(collection_id: @collection.id,
                                           collection_keyword_id: collection_keyword_id)
      refer_count = CollectionToCollectionKeyword.where(collection_keyword_id: collection_keyword_id).count
      CollectionKeyword.find(collection_keyword_id).update(refer_count: refer_count)
    end
  end
end
