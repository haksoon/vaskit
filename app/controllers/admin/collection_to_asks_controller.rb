class Admin::CollectionToAsksController < Admin::HomeController

  # # GET /admin/collection_to_asks/:id.json
  def index
    collection_to_asks = CollectionToAsk.where(collection_id: params[:collection_id]).as_json(include: [:collection, ask: {include: [:user, :left_ask_deal, :right_ask_deal]}])
    render json: {collection_to_asks: collection_to_asks}
  end

  # POST /admin/collection_to_asks.json
  def create
    collection_id = params[:collection_id]
    ask_ids = params[:ask_ids].split(",")
    success_ids = []
    ask_ids.each do |ask_id|
      ask = Ask.where(:id => ask_id)
      if ask.exists? && CollectionToAsk.where(collection_id: collection_id, ask_id: ask_id).count == 0
        last_collection_to_ask = CollectionToAsk.where(collection_id: collection_id).last
        seq = last_collection_to_ask ? last_collection_to_ask.seq + 1 : 1
        CollectionToAsk.create(collection_id: collection_id, ask_id: ask_id, seq: seq)
        success_ids << ask_id
      end
    end
    collection_to_asks = CollectionToAsk.where("collection_id = ? AND ask_id IN (?)", collection_id, success_ids).as_json(include: [:collection, ask: {include: [:user, :left_ask_deal, :right_ask_deal]}])

    # 해당 ask가 몇 번 포함되어있는지 warning 줄 것
    render json: {success_ids: success_ids, collection_to_asks: collection_to_asks}
  end

  # POST /admin/collection_to_asks/:id.json
  def update
    is_up = params[:is_up] == "true" ? true : false
    collection_to_ask = CollectionToAsk.find(params[:id])

    collection_id = collection_to_ask.collection_id
    seq = collection_to_ask.seq
    target_seq = is_up ? seq - 1 : seq + 1
    target_collection_to_ask = CollectionToAsk.find_by(collection_id: collection_id, seq: target_seq)

    if target_collection_to_ask.blank?
      status = "not_exists"
    else
      status = "success"
      collection_to_ask.update(seq: target_seq)
      target_collection_to_ask.update(seq: seq)
      target_collection_to_ask_id = target_collection_to_ask.id
    end

    render json: {status: status, target_collection_to_ask_id: target_collection_to_ask_id}
  end

  # DELETE /admin/collection_to_asks/:id.json
  def destroy
    collection_to_ask = CollectionToAsk.find(params[:id]).destroy
    collection_id = collection_to_ask.collection_id
    seq = collection_to_ask.seq
    target_collection_to_asks = CollectionToAsk.where('collection_id = ? AND seq > ?', collection_id, seq)
    target_collection_to_asks.each do |collection_to_ask|
      seq = collection_to_ask.seq - 1
      collection_to_ask.update(seq: seq)
    end
    render json: {}
  end

end
