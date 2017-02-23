class Admin::CollectionToAsksController < Admin::HomeController
  # POST /admin/collection_to_asks
  def create
    @ask = Ask.where(id: params[:ask_id]).first
    @ask_count = CollectionToAsk.where(ask_id: params[:ask_id]).count
  end
end
