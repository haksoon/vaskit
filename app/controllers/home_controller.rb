# coding : utf-8
class HomeController < ApplicationController
  
  def index
    @user_categories = []
    if current_user
      @my_votes = Vote.where(:user_id => current_user.id)
      @user_categories = UserCategory.where(:user_id => current_user.id).map(&:category_id)
    elsif @visitor
      @my_votes = Vote.where(:visitor_id => @visitor.id)  
    end
    
    case params[:type]
      when "user"
        @asks = Ask.where(:user_id => params[:keyword]).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "hash_tag"
        hash_tags = HashTag.where("keyword like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where(:id => hash_tags.map(&:ask_id) ).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "ask_deal"
        ask_deal = AskDeal.find_by_id(params[:keyword])
        @asks = Ask.where("left_ask_deal_id = ? OR right_ask_deal_id = ?", ask_deal.id, ask_deal.id).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete]) if ask_deal
      when "brand"
        ask_deals = AskDeal.where("brand like ?", "%#{params[:keyword]}%" )
        @asks = Ask.where("left_ask_deal_id in (?) OR right_ask_deal_id = (?)", ask_deals.map(&:id), ask_deals.map(&:id)).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete]) unless ask_deals.blank?
      when "my_ask"
        @asks = Ask.where(:user_id => current_user.id).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "vote_ask"
        @asks = Ask.where(:id => @my_votes.map(&:ask_id).uniq ).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "comment_ask"  
        @asks = Ask.where(:id => Comment.where(:user_id => current_user.id).map(&:ask_id).uniq ).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
      when "my_ask_in_progress"
        @asks = Ask.where(:user_id => current_user.id, :be_completed => false).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])  
      else
        if @user_categories.blank?
          @asks = Ask.where(:be_completed => false).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
        else
          @asks = Ask.where(:be_completed => false, :category_id => @user_categories).order("id desc").as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete])
        end 
    end
    # 키워드만 넘어왔을 경우.
    # 찾아야 할 데이터,해당 유저가 쓴 ask, 해시태그 , 상품명, 브랜드
    
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
  
end
