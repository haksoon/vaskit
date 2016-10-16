# coding : utf-8
class AsksController < ApplicationController
  before_action :set_ask, only: [:show, :edit, :update, :destroy, :vote, :ask_complete, :create_complete]

  before_filter :auth_admin, :only => ["destroy"]

  def show
    if current_user
      Alram.where(:ask_id => @ask.id, :user_id => current_user.id).each do |alram|
        alram.record_timestamps = false #updated_at 안바뀌게
        alram.update(:is_read => true)
        alram.record_timestamps = true #updated_at 안바뀌게
      end
    end
    @asks = Ask.where(:id => @ask.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, {:comments => {:include => :user}} ])
    # @detail_vote_count = @ask.detail_vote_count #AJS추가(삭제)
    if current_user
      @my_votes = Vote.where(:user_id => current_user.id)
      @my_like_ask = AskLike.where(:user_id => current_user.id) #AJS추가
      @my_like_comment = CommentLike.where(:user_id => current_user.id) #AJS추가
    elsif @visitor
      @my_votes = Vote.where(:visitor_id => @visitor.id)
      @my_like_ask = [] #AJS추가
      @my_like_comment = [] #AJS추가
    end
  end

  # GET /asks/ask_id/show_detail.json
  def show_detail
    ask = Ask.find(params[:id])
    detail_vote_count = ask.detail_vote_count
    render :json => {:detail_vote_count => detail_vote_count}
  end

  # POST /asks/ask_id/like
  def like
    already_like = false
    ask = Ask.find(params[:id])
    ask_like = AskLike.where(:user_id => current_user.id, :ask_id => params[:id]).first
    if ask_like
      already_like = true
      ask_like.destroy
      ask.update(:like_count => ask.like_count - 1)
    else
      ask_like = AskLike.create(:user_id => current_user.id, :ask_id => params[:id])
      ask.update(:like_count => ask.like_count + 1)

      if ask.user_id != ask_like.user_id #&& Alram.where(:user_id => ask.user_id, :send_user_id => current_user.id, :ask_id => ask.id).blank?
      if User.find_by_id(ask.user_id).alram_1 == true #알림 옵션 체크
        alram = Alram.where(:user_id => ask.user_id, :ask_id => ask.id).where("alram_type like ?", "like_ask_%").first
        if alram
          alram.update(:is_read => false, :send_user_id => current_user.id, :alram_type => "like_ask_" + AskLike.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s )
        else
          Alram.create(:user_id => ask.user_id, :send_user_id => current_user.id, :ask_id => ask.id, :alram_type => "like_ask_" + AskLike.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s )
        end
      end
      end
    end
    render :json => {:already_like => already_like, :ask_like => ask_like}
  end

  def destroy
    Ask.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

  # GET /posts/new
  def new
    if current_user
      @ask = Ask.new
    else
      redirect_to "/landing"
    end
  end

  # GET /asks/1/edit
  def edit
    if current_user
      if current_user.id == @ask.user_id
        @left_ask_deal = @ask.left_ask_deal
        @right_ask_deal = @ask.right_ask_deal
      else
        flash[:ask_create] = "수정 권한이 없습니다"
        redirect_to root_path
      end
    else
      redirect_to "/landing"
    end
  end

  # POST /asks
  # POST /asks.json
  def create
    left_deal_params = params[:left_deal]
    left_image = nil
    left_deal_is_modify = false


    left_preview_image = PreviewImage.find_by_id(left_deal_params[:image_id])
    if left_preview_image
      left_image = left_preview_image.image.styles[:crop]
    end

    if left_deal_params[:deal_id].blank?
      left_deal = Deal.create(:title => left_deal_params[:title], :brand => left_deal_params[:brand], :price => left_deal_params[:price], :link => left_deal_params[:link], :spec1 => left_deal_params[:spec1], :spec2 => left_deal_params[:spec2], :spec3 => left_deal_params[:spec3], :image => left_image)
    else
      left_deal = Deal.find(left_deal_params[:deal_id])
      # if left_image.blank?
      #   left_image = left_deal.image
      # else
      #   left_deal_is_modify = true
      # end                                   # 이 다섯 줄은 왜 있는지 모르겠넹...
      unless left_deal.title == left_deal_params[:title] && left_deal.brand == left_deal_params[:brand] && left_deal.price == left_deal_params[:price].to_i
        left_deal_is_modify = true
      end
    end

    left_ask_deal = AskDeal.create(:deal_id => left_deal.id, :user_id => current_user.id, :title => left_deal_params[:title], :brand => left_deal_params[:brand], :link => left_deal_params[:link],
                                    :price => left_deal_params[:price], :spec1 => left_deal_params[:spec1], :spec2 => left_deal_params[:spec2], :spec3 => left_deal_params[:spec3],
                                    :image => left_image, :is_modify => left_deal_is_modify)

    right_deal_params = params[:right_deal]
    right_image = nil
    right_deal_is_modify = false

    right_preview_image = PreviewImage.find_by_id(right_deal_params[:image_id])
    if right_preview_image
      right_image = right_preview_image.image.styles[:crop]
    end

    if right_deal_params[:deal_id].blank?
      right_deal = Deal.create(:title => right_deal_params[:title], :brand => right_deal_params[:brand], :price => right_deal_params[:price], :link => right_deal_params[:link], :spec1 => right_deal_params[:spec1], :spec2 => right_deal_params[:spec2], :spec3 => right_deal_params[:spec3], :image => right_image)
    else
      right_deal = Deal.find(right_deal_params[:deal_id])
      # if right_image.blank?
      #   right_image = right_deal.image
      # else
      #   right_deal_is_modify = true
      # end                                   # 이 다섯 줄은 왜 있는지 모르겠넹...
      unless right_deal.title == right_deal_params[:title] && right_deal.brand == right_deal_params[:brand] && right_deal.price == right_deal_params[:price].to_i
        right_deal_is_modify = true
      end
    end

    right_ask_deal = AskDeal.create(:deal_id => right_deal.id, :user_id => current_user.id, :title => right_deal_params[:title], :brand => right_deal_params[:brand], :link => right_deal_params[:link],
                                    :price => right_deal_params[:price], :spec1 => right_deal_params[:spec1], :spec2 => right_deal_params[:spec2], :spec3 => right_deal_params[:spec3],
                                    :image => right_image, :is_modify => right_deal_is_modify)

    params[:ask][:user_id] = current_user.id
    params[:ask][:left_ask_deal_id] = left_ask_deal.id
    params[:ask][:right_ask_deal_id] = right_ask_deal.id

    params["ask"]["message"].gsub!(/\S#\S/){|message| message.gsub("#", " #")} #해시태그 띄어쓰기 해줌
    @ask = Ask.create(ask_params)

    # 카테고리가 없는 경우 카테고리 추가
    unless UserCategory.where(:user_id => current_user.id).blank? #AJS추가 유저가 카테고리를 수동으로 설정한 경우에 한해, 신규 카테고리 내용 글 쓰면 카테고리를 추가해서 보여줌
      if @ask.category_id && !UserCategory.where(:user_id => current_user.id).map(&:category_id).include?(@ask.category_id)
        UserCategory.create(:user_id => current_user.id, :category_id => @ask.category_id)
      end
    end

    hash_tags = @ask.message.scan(/#[0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]*/)
    hash_tags.each do |hash_tag|
      hash_tag = hash_tag.tr("#","").tr(",","")
      HashTag.create(:ask_id => @ask.id, :user_id => current_user.id, :keyword => hash_tag)
    end

    flash[:ask_create] = "게시글 작성 완료! 친구들에게 공유해보세요 :)"
    flash[:ask_id] = @ask.id

    redirect_to root_path

    if User.find(@ask.user_id).user_role == "user"
      ask = @ask
      admins = ['junsikahn@vaskit.kr', 'haksoon@vaskit.kr', 'seokkiyoon@vaskit.kr', 'ice1134@naver.com', 'dammi0119@gmail.com', 'duddk0218@naver.com', 'khj120920@naver.com']
      admins.each do |admin|
        AdminMailer.delay.ask_submitted(ask, admin)
      end
    end
  end

  # PATCH/PUT /asks/1
  # PATCH/PUT /asks/1.json
  def update
    left_deal_params = params[:left_deal]
    left_image = nil
    left_deal_is_modify = false

    left_preview_image = PreviewImage.find_by_id(left_deal_params[:image_id])
    if left_preview_image
      left_image = left_preview_image.image.styles[:crop]
      @ask.left_ask_deal.update(:image => left_image)
    end

    if left_deal_params[:deal_id].blank?
      left_deal_params.except!("deal_id")
      left_deal_params[:is_modify] = true
    else
      left_deal = Deal.find(left_deal_params[:deal_id])
      # if left_image.blank?
      #   left_image = left_deal.image
      # else
      #   left_deal_is_modify = true
      # end
      unless left_deal.title == left_deal_params[:title] && left_deal.brand == left_deal_params[:brand] && left_deal.price == left_deal_params[:price].to_i
        left_deal_is_modify = true
      end
      @ask.left_ask_deal.update(:image => left_image)
      left_deal_params[:image] = left_image
    end
    left_deal_params.except!("image_id")
    left_deal_params.except!("image")
    unlocked_params = ActiveSupport::HashWithIndifferentAccess.new(left_deal_params)
    @ask.left_ask_deal.update(unlocked_params)


    right_deal_params = params[:right_deal]
    right_image = nil
    right_deal_is_modify = false

    right_preview_image = PreviewImage.find_by_id(right_deal_params[:image_id])
    if right_preview_image
      right_image = right_preview_image.image.styles[:crop]
      @ask.right_ask_deal.update(:image => right_image)
    end

    if right_deal_params[:deal_id].blank?
      right_deal_params.except!("deal_id")
      right_deal_params[:is_modify] = true
    else
      right_deal = Deal.find(right_deal_params[:deal_id])
      # if right_image.blank?
      #   right_image = right_deal.image
      # else
      #   right_deal_is_modify = true
      # end
      unless right_deal.title == right_deal_params[:title] && right_deal.brand == right_deal_params[:brand] && right_deal.price == right_deal_params[:price].to_i
        right_deal_is_modify = true
      end
      @ask.right_ask_deal.update(:image => right_image)
      right_deal_params[:image] = right_image
    end
    right_deal_params.except!("image_id")
    right_deal_params.except!("image")
    unlocked_params = ActiveSupport::HashWithIndifferentAccess.new(right_deal_params)
    @ask.right_ask_deal.update(unlocked_params)

    params["ask"]["message"].gsub!(/\S#\S/){|message| message.gsub("#", " #")} #해시태그 띄어쓰기 해줌
    @ask.update(ask_params)

    # 카테고리가 없는 경우 카테고리 추가
    unless UserCategory.where(:user_id => current_user.id).blank? #AJS추가 유저가 카테고리를 수동으로 설정한 경우에 한해, 신규 카테고리 내용 글 쓰면 카테고리를 추가해서 보여줌
      if @ask.category_id && !UserCategory.where(:user_id => current_user.id).map(&:category_id).include?(@ask.category_id)
        UserCategory.create(:user_id => current_user.id, :category_id => @ask.category_id)
      end
    end

    HashTag.destroy_all(:ask_id => @ask.id) #AJS추가 - 해쉬태그 기존 값을 모두 삭제 후 업데이트된 내용으로 재 설정
    hash_tags = @ask.message.scan(/#[0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]*/)
    hash_tags.each do |hash_tag|
      hash_tag = hash_tag.tr("#","").tr(",","")
      HashTag.create(:ask_id => @ask.id, :user_id => current_user.id, :keyword => hash_tag) # if HashTag.where(:ask_id => @ask.id, :keyword => hash_tag).blank?
    end

    # flash[:redirect_url] = "/" #AJS추가(삭제)
    flash[:ask_create] = "게시글 수정 완료! 친구들에게 공유해보세요 :)"
    flash[:ask_id] = @ask.id

    redirect_to "/asks/#{@ask.id}"
  end

  #GET /asks/:id/ask_complete
  def ask_complete
    if current_user
      if current_user.id != @ask.user_id
        flash[:ask_create] = "권한이 없습니다"
        redirect_to root_path
      elsif @ask.be_completed == true
        flash[:ask_create] = "이미 종료된 투표입니다"
        redirect_to root_path
      else
        @detail_vote_count = @ask.detail_vote_count
      end
    else
      redirect_to "/landing"
    end
  end

  #GET /asks/:id/create_complete
  def create_complete
    if AskComplete.where(:user_id => current_user.id, :ask_id => @ask.id).blank? #이미 종료한 경우
      @ask.update(:be_completed => true)
      AskComplete.create(:user_id => current_user.id, :ask_id => @ask.id, :ask_deal_id => params[:ask_deal_id], :star_point => params[:star_point])
    end

    redirect_to root_path
  end


  # DELETE /asks/1
  # DELETE /asks/1.json
  def destroy
    @ask.destroy
    respond_to do |format|
      format.html { redirect_to asks_path }
      format.json { head :no_ask }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ask
      @ask = Ask.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ask_params
      params.require(:ask).permit(:user_id, :left_ask_deal_id, :right_ask_deal_id, :category_id, :message, :be_completed, :admin_choice, :spec1, :spec2, :spec3)
    end
end
