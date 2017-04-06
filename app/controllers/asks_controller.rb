class AsksController < ApplicationController
  before_action :set_ask, only: [:show, :show_detail, :edit, :update, :destroy]

  # GET /asks
  # GET /asks.json
  def index
    respond_to do |format|
      format.html
      format.json do
        asks = Ask.page(params[:page])
                  .per(Ask::ASK_PER)
                  .order(id: :desc)

        if current_user
          my_votes = Vote.where(user_id: current_user.id)
          my_votes = my_votes.where('updated_at < ?', params[:date].to_datetime) unless params[:date].nil?
          my_votes = my_votes.map(&:ask_id)
          asks = asks.where.not(user_id: current_user.id)
          asks = asks.where.not(id: my_votes) unless my_votes.empty?
        end

        # Event Ask
        events = Event.where('started_at <= ? AND ended_at >= ?', Time.now, Time.now).order(ended_at: :desc)
        asks = asks.where.not(id: events.map(&:ask_id))
        if params[:page].nil? || params[:page] == '1'
          events.each do |event|
            event_ask = event.ask
            asks.unshift(event_ask)
          end
        end

        asks = asks.as_json(include: [:user, :left_ask_deal, :right_ask_deal, :votes, :ask_likes, :ask_complete, :event])
        render json: { asks: asks }
      end
    end
  end

  # GET /asks/:id
  # GET /asks/:id.json
  def show
    respond_to do |format|
      format.html
      format.json do
        ask = @ask

        already_like = false
        like_comments = []
        if current_user
          already_like = ask.fetch_ask_likes(current_user.id)
          like_comments = ask.fetch_comment_likes(current_user.id)
          ask.alarm_read(current_user.id)
        end

        ask = ask.fetch_ask_detail

        render json: {
          ask: ask,
          already_like: already_like,
          like_comments: like_comments
        }
      end
    end
  end

  # GET /asks/:id/show_detail.json
  def show_detail
    detail_vote_count = @ask.detail_vote_count
    render json: { detail_vote_count: detail_vote_count }
  end

  # POST /asks/:id/like.json
  def like
    ask_like = AskLike.find_by(user_id: current_user.id,
                               ask_id: params[:id])
    if ask_like.nil?
      already_like = false
      AskLike.create(user_id: current_user.id, ask_id: params[:id])
      recent_user = current_user
    else
      already_like = true
      ask_like.update(is_deleted: true)
      last_ask_like = AskLike.where(ask_id: params[:id]).last
      recent_user = last_ask_like.user unless last_ask_like.nil?
    end
    ask_like_count = AskLike.where(ask_id: params[:id]).count

    render json: { already_like: already_like,
                   recent_user: recent_user,
                   ask_like_count: ask_like_count }
  end

  # GET /asks/new
  # GET /asks/new.json
  def new
    respond_to do |format|
      format.html
      format.json do
        if current_user
          ask_tmp = AskTmp.find_by(user_id: current_user.id)
          if ask_tmp
            ask = ask_tmp.as_json(include: [{ left_ask_deal: { include: :preview_image } } , { right_ask_deal: { include: :preview_image } } ])
            ask['id'] = nil
            ask_tmp.destroy
          else
            ask = Ask.new.as_json
            ask['left_ask_deal'] = ask['right_ask_deal'] = AskDeal.new.as_json
          end
          status = 'success'
        else
          status = 'not_authorized'
        end
        render json: { status: status, ask: ask }
      end
    end
  end

  # POST /asks.json
  def create
    left_deal_params = params[:left_deal]
    right_deal_params = params[:right_deal]

    left_deal_params[:price] = left_deal_params[:price].sub(/^[0]*/, '').delete(',').to_i if !left_deal_params.nil? && !left_deal_params[:price].nil?
    right_deal_params[:price] = right_deal_params[:price].sub(/^[0]*/, '').delete(',').to_i if !right_deal_params.nil? && !right_deal_params[:price].nil?

    if left_deal_params.nil? || left_deal_params[:image_id].blank?
      status = 'no_left_image'
      render json: { status: status }
    elsif left_deal_params.nil? || left_deal_params[:title].blank?
      status = 'no_left_title'
      render json: { status: status }
    elsif right_deal_params.nil? || right_deal_params[:image_id].blank?
      status = 'no_right_image'
      render json: { status: status }
    elsif right_deal_params.nil? || right_deal_params[:title].blank?
      status = 'no_right_title'
      render json: { status: status }
    elsif params[:ask].nil? || params[:ask][:message].blank?
      status = 'no_ask_message'
      render json: { status: status }
    else
      # left_ask_deal
      left_image = PreviewImage.find(left_deal_params[:image_id]).image.styles[:square]
      left_deal_is_modify = false
      if left_deal_params[:deal_id].blank?
        left_deal = Deal.create(title: left_deal_params[:title],
                                brand: left_deal_params[:brand],
                                price: left_deal_params[:price],
                                link: left_deal_params[:link],
                                spec1: left_deal_params[:spec1],
                                spec2: left_deal_params[:spec2],
                                spec3: left_deal_params[:spec3],
                                image: left_image)
      else
        left_deal = Deal.find(left_deal_params[:deal_id])
        left_deal_is_modify = true unless left_deal.title == left_deal_params[:title] && left_deal.brand == left_deal_params[:brand] && left_deal.price == left_deal_params[:price].to_i
      end

      left_ask_deal = AskDeal.create(deal_id: left_deal.id,
                                     user_id: current_user.id,
                                     title: left_deal_params[:title],
                                     brand: left_deal_params[:brand],
                                     price: left_deal_params[:price],
                                     link: left_deal_params[:link],
                                     spec1: left_deal_params[:spec1],
                                     spec2: left_deal_params[:spec2],
                                     spec3: left_deal_params[:spec3],
                                     image: left_image,
                                     is_modify: left_deal_is_modify)

      # right_ask_deal
      right_image = PreviewImage.find(right_deal_params[:image_id]).image.styles[:square]
      right_deal_is_modify = false
      if right_deal_params[:deal_id].blank?
        right_deal = Deal.create(title: right_deal_params[:title],
                                 brand: right_deal_params[:brand],
                                 price: right_deal_params[:price],
                                 link: right_deal_params[:link],
                                 spec1: right_deal_params[:spec1],
                                 spec2: right_deal_params[:spec2],
                                 spec3: right_deal_params[:spec3],
                                 image: right_image)
      else
        right_deal = Deal.find(right_deal_params[:deal_id])
        right_deal_is_modify = true unless right_deal.title == right_deal_params[:title] && right_deal.brand == right_deal_params[:brand] && right_deal.price == right_deal_params[:price].to_i
      end

      right_ask_deal = AskDeal.create(deal_id: right_deal.id,
                                      user_id: current_user.id,
                                      title: right_deal_params[:title],
                                      brand: right_deal_params[:brand],
                                      price: right_deal_params[:price],
                                      link: right_deal_params[:link],
                                      spec1: right_deal_params[:spec1],
                                      spec2: right_deal_params[:spec2],
                                      spec3: right_deal_params[:spec3],
                                      image: right_image,
                                      is_modify: right_deal_is_modify)

      # ask
      params[:ask][:user_id] = current_user.id
      params[:ask][:left_ask_deal_id] = left_ask_deal.id
      params[:ask][:right_ask_deal_id] = right_ask_deal.id
      params[:ask][:message].gsub!(/\S#\S/) { |message| message.gsub('#', ' #') } # 해시태그 띄어쓰기 해줌
      ask = Ask.create(ask_params)

      ask.generate_hash_tags
      ask.ask_notifier('new')

      render json: { status: 'success', ask: ask }
    end
  end

  # GET /asks/:id/edit
  # GET /asks/:id/edit.json
  def edit
    respond_to do |format|
      format.html
      format.json do
        if current_user && current_user.id == @ask.user_id
          if @ask.be_completed
            status = 'already_completed'
          else
            ask = @ask.as_json(include: [:left_ask_deal, :right_ask_deal])
            status = 'success'
          end
        else
          status = 'not_authorized'
        end
        render json: { status: status, ask: ask }
      end
    end
  end

  # PUT /asks/:id.json
  def update
    left_deal_params = params[:left_deal]
    right_deal_params = params[:right_deal]

    left_deal_params[:price] = left_deal_params[:price]
                               .sub(/^[0]*/, '')
                               .delete(',')
                               .to_i if !left_deal_params.nil? && !left_deal_params[:price].nil?
    right_deal_params[:price] = right_deal_params[:price]
                                .sub(/^[0]*/, '')
                                .delete(',')
                                .to_i if !right_deal_params.nil? && !right_deal_params[:price].nil?

    if left_deal_params[:image_id].blank? && @ask.left_ask_deal.image.nil?
      status = 'no_left_image'
      render json: { status: status }
    elsif left_deal_params[:title].blank?
      status = 'no_left_title'
      render json: { status: status }
    elsif right_deal_params[:image_id].blank? && @ask.right_ask_deal.image.nil?
      status = 'no_right_image'
      render json: { status: status }
    elsif right_deal_params[:title].blank?
      status = 'no_right_title'
      render json: { status: status }
    elsif params[:ask][:message].blank?
      status = 'no_ask_message'
      render json: { status: status }
    else
      # left_ask_deal
      unless left_deal_params[:image_id].blank?
        left_image = PreviewImage.find(left_deal_params[:image_id]).image.styles[:square]
        left_deal_params[:image] = left_image
      end
      left_deal_params.except!(:image_id)

      if left_deal_params[:deal_id].blank?
        left_deal = Deal.create(title: left_deal_params[:title],
                                brand: left_deal_params[:brand],
                                price: left_deal_params[:price],
                                link: left_deal_params[:link],
                                image: left_image,
                                spec1: left_deal_params[:spec1],
                                spec2: left_deal_params[:spec2],
                                spec3: left_deal_params[:spec3])
        left_deal_params[:is_modify] = false
      else
        left_deal = Deal.find(left_deal_params[:deal_id])
        left_deal_params[:is_modify] = true unless left_deal.title == left_deal_params[:title] && left_deal.brand == left_deal_params[:brand] && left_deal.price == left_deal_params[:price].to_i
      end

      unlocked_params = ActiveSupport::HashWithIndifferentAccess.new(left_deal_params)
      @ask.left_ask_deal.update(unlocked_params)

      # right_ask_deal
      unless right_deal_params[:image_id].blank?
        right_image = PreviewImage.find(right_deal_params[:image_id]).image.styles[:square]
        right_deal_params[:image] = right_image
      end
      right_deal_params.except!(:image_id)

      if right_deal_params[:deal_id].blank?
        right_deal = Deal.create(title: right_deal_params[:title],
                                 brand: right_deal_params[:brand],
                                 price: right_deal_params[:price],
                                 link: right_deal_params[:link],
                                 image: right_image,
                                 spec1: right_deal_params[:spec1],
                                 spec2: right_deal_params[:spec2],
                                 spec3: right_deal_params[:spec3])
        right_deal_params[:is_modify] = false
      else
        right_deal = Deal.find(right_deal_params[:deal_id])
        right_deal_params[:is_modify] = true unless right_deal.title == right_deal_params[:title] && right_deal.brand == right_deal_params[:brand] && right_deal.price == right_deal_params[:price].to_i
      end

      unlocked_params = ActiveSupport::HashWithIndifferentAccess.new(right_deal_params)
      @ask.right_ask_deal.update(unlocked_params)

      # ask
      params[:ask][:message].gsub!(/\S#\S/) { |message| message.gsub('#', ' #') } # 해시태그 띄어쓰기 해줌
      @ask.update(ask_params)

      @ask.generate_hash_tags
      @ask.ask_notifier('edit')

      render json: { status: 'success', ask: @ask }
    end
  end

  # DELETE /asks/:id.json
  def destroy
    ask = @ask
    ask.update(be_completed: true)
    AskComplete.create(user_id: current_user.id,
                       ask_id: ask.id,
                       ask_deal_id: params[:ask_deal_id],
                       star_point: params[:star_point],
                       left_vote_count: ask.left_ask_deal.vote_count,
                       right_vote_count: ask.right_ask_deal.vote_count)
    ask.ask_notifier('complete')

    already_like = false
    like_comments = []
    if current_user
      already_like = ask.fetch_ask_likes(current_user.id)
      like_comments = ask.fetch_comment_likes(current_user.id)
      ask.alarm_read(current_user.id)
    end

    ask = ask.fetch_ask_detail

    render json: {
      ask: ask,
      already_like: already_like,
      like_comments: like_comments
    }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ask
    @ask = Ask.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ask_params
    params.require(:ask)
          .permit(:user_id,
                  :left_ask_deal_id,
                  :right_ask_deal_id,
                  :message,
                  :be_completed,
                  :spec1,
                  :spec2,
                  :spec3)
  end
end
