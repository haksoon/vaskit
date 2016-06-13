# coding : utf-8
class HomeController < ApplicationController

  def index
    @user_categories = []
    if current_user
      @my_votes = Vote.where(:user_id => current_user.id)
      @user_categories = UserCategory.where(:user_id => current_user.id).map(&:category_id)
      @my_ask_count = Ask.where(:user_id => current_user.id).count #AJS추가
      @my_vote_count = Vote.where(:user_id => current_user.id).count #AJS추가
      @my_comment_count = Comment.where(:user_id => current_user.id).count #AJS추가
      @in_progress_count = Ask.where(:user_id => current_user.id, :be_completed => false).count #AJS추가
      @alram_count = Alram.where(:user_id => current_user.id, :is_read => false).count #AJS추가
    elsif @visitor
      @my_votes = Vote.where(:visitor_id => @visitor.id)
    end

    @type = params[:type]

    case params[:type]
      when "user"
        user_id = User.where("string_id like ?", "%#{params[:keyword]}%" ).select(:string_id).uniq.to_s #AJS추가
        flash[:keyword] = user_id #AJS추가
        @asks = Ask.where(:user_id => params[:keyword]).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "hash_tag"
        flash[:keyword] = params[:keyword] #AJS추가
        hash_tags = HashTag.where("keyword like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where(:id => hash_tags.map(&:ask_id) ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "ask_deal"
        flash[:keyword] = params[:keyword] #AJS추가
        ask_deals = AskDeal.where("title like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where("left_ask_deal_id in (?) OR right_ask_deal_id in (?)", ask_deals.map(&:id), ask_deals.map(&:id)).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete]) unless ask_deals.blank?
      when "brand"
        flash[:keyword] = params[:keyword] #AJS추가
        ask_deals = AskDeal.where("brand like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where("left_ask_deal_id in (?) OR right_ask_deal_id in (?)", ask_deals.map(&:id), ask_deals.map(&:id)).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete]) unless ask_deals.blank?
      when "my_ask"
        @asks = Ask.where(:user_id => current_user.id).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "vote_ask"
        @asks = Ask.where(:id => @my_votes.map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "comment_ask"
        @asks = Ask.where(:id => Comment.where(:user_id => current_user.id).map(&:ask_id).uniq ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "my_ask_in_progress"
        @asks = Ask.where(:user_id => current_user.id, :be_completed => false).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
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
        @asks = Ask.where(:id => ask_ids ).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      else
        if @user_categories.blank? || @user_categories.length == 12 #전체 카테고리
          if @my_votes.blank?
            ranking_ask_ids = RankAsk.where(:category_id => nil).pluck(:ask_id)
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          else
            ranking_ask_ids = RankAsk.where(:category_id => nil).where("ask_id not in (?)", @my_votes.map(&:ask_id)).pluck(:ask_id)
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          end
          if @ranking_asks.blank?
            @asks = Ask.where(:be_completed => false).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
          else
            @asks = Ask.where(:be_completed => false).where("id not in (?)", ranking_ask_ids).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
          end
        else
          if @my_votes.blank?
            ranking_ask_ids = RankAsk.where(:category_id => @user_categories).pluck(:ask_id).uniq
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          else
            ranking_ask_ids = RankAsk.where(:category_id => @user_categories).where("ask_id not in (?)", @my_votes.map(&:ask_id)).pluck(:ask_id).uniq
            if current_user
              @ranking_asks = Ask.where(:id => ranking_ask_ids).where("user_id <> ?", current_user.id).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            else
              @ranking_asks = Ask.where(:id => ranking_ask_ids).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, :rank_ask])
            end
            @ranking_asks = @ranking_asks.sort_by{ |k| k["rank_ask"]["ranking"] }
          end
          if @ranking_asks.blank?
            @asks = Ask.where(:be_completed => false, :category_id => @user_categories).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
          else
            @asks = Ask.where(:be_completed => false, :category_id => @user_categories).where("id not in (?)", ranking_ask_ids).page(params[:page]).per(Ask::ASK_PER).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
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

end
