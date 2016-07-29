# coding : utf-8
class HomeController < ApplicationController

  def index
    @user_categories = []
    if current_user
      @user_categories = UserCategory.where(:user_id => current_user.id).map(&:category_id)
      @my_votes = Vote.where(:user_id => current_user.id)
      @my_like_ask = AskLike.where(:user_id => current_user.id) #AJS추가
      @my_like_comment = CommentLike.where(:user_id => current_user.id) #AJS추가
    elsif @visitor
      @my_votes = Vote.where(:visitor_id => @visitor.id)
      @my_like_ask = [] #AJS추가
      @my_like_comment = [] #AJS추가
    end

    @type = params[:type]

    case params[:type]
      when "user"
        flash[:keyword] = params[:keyword] #AJS추가
        users = User.where("string_id like ?", "#{params[:keyword]}%") #AJS추가
        # @asks = Ask.where(:user_id => params[:keyword]).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
        @asks = Ask.where(:user_id => users.map(&:id)).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) #AJS추가(수정)
      when "hash_tag"
        flash[:keyword] = params[:keyword] #AJS추가
        hash_tags = HashTag.where("keyword like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where(:id => hash_tags.map(&:ask_id) ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      when "ask_deal"
        flash[:keyword] = params[:keyword] #AJS추가
        ask_deals = AskDeal.where("title like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where("left_ask_deal_id in (?) OR right_ask_deal_id in (?)", ask_deals.map(&:id), ask_deals.map(&:id)).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) unless ask_deals.blank?
      when "brand"
        flash[:keyword] = params[:keyword] #AJS추가
        ask_deals = AskDeal.where("brand like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where("left_ask_deal_id in (?) OR right_ask_deal_id in (?)", ask_deals.map(&:id), ask_deals.map(&:id)).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) unless ask_deals.blank?
      when "my_ask"
        @asks = Ask.where(:user_id => current_user.id).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      when "vote_ask"
        @asks = Ask.where(:id => @my_votes.map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      when "comment_ask"
        @asks = Ask.where(:id => Comment.where(:user_id => current_user.id).map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      when "my_ask_in_progress"
        @asks = Ask.where(:user_id => current_user.id, :be_completed => false).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      when "my_like_ask"
        @asks = Ask.where(:id => @my_like_ask.map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      when "none" #통합 검색
        keyword = params[:keyword]
        flash[:keyword] = params[:keyword] #AJS추가
        user_ask_ids = Ask.where(:user_id => User.where("string_id like ?", "%#{keyword}%").pluck(:id)).pluck(:id)
        hash_tag_ask_ids = Ask.where(:id => HashTag.where("keyword like ?", "%#{keyword}%" ).pluck(:ask_id) ).pluck(:id)
        title_ask_deal_ids = AskDeal.where("title like ?", "%#{keyword}%" ).pluck(:id)
        title_ask_ids = Ask.where("left_ask_deal_id IN (?) OR right_ask_deal_id IN (?)", title_ask_deal_ids, title_ask_deal_ids).pluck(:id)
        brand_ask_deal_ids = AskDeal.where("brand like ?", "%#{keyword}%" ).pluck(:id)
        brand_ask_ids = Ask.where("left_ask_deal_id in (?) OR right_ask_deal_id in (?)", brand_ask_deal_ids, brand_ask_deal_ids).pluck(:id)
        ask_ids = (user_ask_ids + hash_tag_ask_ids + title_ask_ids + brand_ask_ids).uniq
        @asks = Ask.where(:id => ask_ids ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      when "vote_yet"
        @asks = Ask.where(:be_completed => false).where("id not in (?) AND user_id not in (?)", @my_votes.map(&:ask_id), current_user.id).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
      else
        if @user_categories.blank? || @user_categories.length == 12 #전체 카테고리
          if @my_votes.blank?
            ranking_ask_ids = RankAsk.where(:category_id => nil).pluck(:ask_id)
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          else
            ranking_ask_ids = RankAsk.where(:category_id => nil).where("ask_id not in (?)", @my_votes.map(&:ask_id)).pluck(:ask_id)
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          end
          if @ranking_asks.blank?
            @asks = Ask.where(:be_completed => false).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
          else
            @asks = Ask.where(:be_completed => false).where("id not in (?)", ranking_ask_ids).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
          end
        else
          if @my_votes.blank?
            ranking_ask_ids = RankAsk.where(:category_id => @user_categories).pluck(:ask_id).uniq
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          else
            ranking_ask_ids = RankAsk.where(:category_id => @user_categories).where("ask_id not in (?)", @my_votes.map(&:ask_id)).pluck(:ask_id).uniq
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask, {:comments => {:include => :user}} ])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          end
          if @ranking_asks.blank?
            @asks = Ask.where(:be_completed => false, :category_id => @user_categories).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
          else
            @asks = Ask.where(:be_completed => false, :category_id => @user_categories).where("id not in (?)", ranking_ask_ids).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
          end
        end
    end
    respond_to do |format|
      format.html {
        if params[:type] != nil && @asks.blank?
          redirect_to "/home/no_result"
        end
      }
      format.json {render :json => { :asks => @asks }}
    end
  end

  def show_detail
    ask = Ask.find(params[:id])
    detail_vote_count = ask.detail_vote_count
    render :json => {:detail_vote_count => detail_vote_count}
  end

  #GET /home/set_cateogry
  def set_category
    UserCategory.delete_all(:user_id => current_user.id) if current_user
    if params[:category_ids] == "all"
      @asks = Ask.all.order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal])
    else
      params[:category_ids].split(",").each do |category_id|
        UserCategory.create(:user_id => current_user.id, :category_id => category_id) if current_user
      end
    end
    redirect_to root_path
  end


  #GET /home/no_result
  def no_result
    @user_categories = []
    @user_categories = UserCategory.where(:user_id => current_user.id).map(&:category_id) if current_user
  end

  #POST /home/like
  def like
    already_like = false
    ask = Ask.find(params[:id])
    ask_like = AskLike.where(:user_id => current_user.id, :ask_id => params[:id]).first
    if ask_like
      already_like = true
      ask_like.delete
      ask.update(:like_count => ask.like_count - 1)
    else
      ask_like = AskLike.create(:user_id => current_user.id, :ask_id => params[:id])
      ask.update(:like_count => ask.like_count + 1)

      if ask.user_id != ask_like.user_id && Alram.where(:user_id => ask.user_id, :send_user_id => current_user.id, :ask_id => ask.id).blank?
        alram = Alram.where(:user_id => ask.user_id, :ask_id => ask.id).where("alram_type like ?", "like_ask_%").first
        if alram
          alram.update(:is_read => false, :send_user_id => current_user.id, :alram_type => "like_ask_" + AskLike.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s )
        else
          Alram.create(:user_id => ask.user_id, :send_user_id => current_user.id, :ask_id => ask.id, :alram_type => "like_ask_" + AskLike.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s )
        end
      end
    end
    render :json => {:already_like => already_like, :ask_like => ask_like}
  end

  #POST /home/welcome > visit check
  def welcome
    device = params[:device] unless params[:device].blank?
    browser = params[:browser] unless params[:browser].blank?
    # href = params[:href] unless params[:href].blank?
    # action = params[:action] unless params[:action].blank?
    # referrer = params[:referrer] unless params[:referrer].blank?
    if current_user
      user_id = current_user.id
      UserVisit.create(:user_id => user_id, :device => device, :browser => browser)
      # UserVisit.create(:user_id => user_id, :device => device, :browser => browser, :href => href, :action => action, :referrer => referrer)
    elsif @visitor
      visitor_id = @visitor.id
      # UserVisit.create(:visitor_id => visitor_id, :device => device, :browser => browser, :href => href, :action => action, :referrer => referrer)
      UserVisit.create(:visitor_id => visitor_id, :device => device, :browser => browser)
    end
    render :json => {}
  end

end
