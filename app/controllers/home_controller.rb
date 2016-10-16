# coding : utf-8
class HomeController < ApplicationController

  def index
    welcome if params[:page] == nil && params[:type] == nil
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
        @asks = "visitor" unless current_user #비회원이 해당 URL로 접속했을 때 랜딩페이지로 리다이렉트시킴
        @asks = Ask.where(:user_id => current_user.id).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) if current_user
      when "vote_ask"
        @asks = "visitor" unless current_user #비회원이 해당 URL로 접속했을 때 랜딩페이지로 리다이렉트시킴
        @asks = Ask.where(:id => @my_votes.map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) if current_user
      when "comment_ask"
        @asks = "visitor" unless current_user #비회원이 해당 URL로 접속했을 때 랜딩페이지로 리다이렉트시킴
        @asks = Ask.where(:id => Comment.where(:user_id => current_user.id).map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) if current_user
      when "my_ask_in_progress"
        @asks = "visitor" unless current_user #비회원이 해당 URL로 접속했을 때 랜딩페이지로 리다이렉트시킴
        @asks = Ask.where(:user_id => current_user.id, :be_completed => false).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) if current_user
      when "my_like_ask"
        @asks = "visitor" unless current_user #비회원이 해당 URL로 접속했을 때 랜딩페이지로 리다이렉트시킴
        @asks = Ask.where(:id => @my_like_ask.map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) if current_user
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
        @asks = "visitor" unless current_user #비회원이 해당 URL로 접속했을 때 랜딩페이지로 리다이렉트시킴
        @asks = Ask.where(:be_completed => false).where("id not in (?) AND user_id not in (?)", @my_votes.map(&:ask_id), current_user.id).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ]) if current_user
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
        if @asks == "visitor"
          redirect_to "/landing"
        elsif params[:type] != nil && @asks.blank?
          redirect_to "/home/no_result"
        end
      }
      format.json {render :json => { :asks => @asks }}
    end
  end

  #GET /home/set_cateogry
  def set_category
    UserCategory.destroy_all(:user_id => current_user.id) if current_user
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

  def welcome
    referer_host = request.referer ? URI.parse(URI.encode(request.referer.strip)).host.to_s : "None"
    unless referer_host == request.host
      referer = request.referer ? URI.parse(URI.encode(request.referer.strip)).to_s : "None"
      ua = request.headers['User-Agent'] ? request.headers['User-Agent'] : "unknown"

      if ua.match(/iPhone/i)
        device = cookies['gcm_key'] ? "App_iOS" : "iPhone"
      elsif ua.match(/Android/i)
        device = cookies['gcm_key'] ? "App_AOS" : "Android"
      elsif ua.match(/Win|Windows/i)
        device = "Windows"
      elsif ua.match(/Mac|MacIntel/i)
        device = "Mac"
      elsif ua.match(/Linux/i)
        device = "Linux"
      elsif ua.match(/iPod|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson/i)
        device = "mobile_etc"
      else
        device = "unknown"
      end

      if ua.match(/NAVER/i)
        browser = "NaverAPP"
      elsif ua.match(/Daum/i)
        browser = "DaumAPP"
      elsif ua.match(/KAKAOTALK|KAKAOSTORY/i)
        browser = "KakaoAPP"
      elsif ua.match(/Facebook|FB/i)
        browser = "FacebookAPP"
      elsif ua.match(/MSIE|Trident/i)
        browser = "IE"
      elsif ua.match(/Edge/i)
        browser = "Edge"
      elsif ua.match(/Opera|OPR|OPiOS/i)
        browser = "Opera"
      elsif ua.match(/Chrome|CriOS/i)
        browser = "Chrome"
      elsif ua.match(/Firefox|FxiOS/i)
        browser = "FireFox"
      elsif ua.match(/Safari/i)
        browser = "Safari"
      else
        browser = "unknown"
      end

      if device == "App_AOS" || device == "App_iOS"
        set_gcm_key
      end

      user_id = current_user.id unless current_user.blank?
      visitor_id = @visitor.id unless @visitor.blank?
      UserVisit.create(:user_id => user_id, :visitor_id => visitor_id, :device => device, :browser => browser, :referer_host => referer_host, :referer_full => referer, :user_agent => ua)
    end
  end

end
