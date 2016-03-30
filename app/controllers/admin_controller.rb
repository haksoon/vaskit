# coding : utf-8
class AdminController < ApplicationController
  before_filter :auth_admin
  
  def index
    @notices = Notice.all.order("id desc")
    category_id = params[:category_id]
    if category_id
      @rank_asks = RankAsk.where(:category_id => category_id).order("ranking asc")
      if @rank_asks.blank?
        @asks = Ask.where(:category_id => category_id).order("id desc")
      else
        @asks = Ask.where(:category_id => category_id).where("id not in (?)", @rank_asks.map(&:ask_id)).order("id desc")
      end 
      @category = Category.find(category_id)
    else
      @rank_asks = RankAsk.where(:category_id => nil).order("ranking asc")
      if @rank_asks.blank?
        @asks = Ask.all.order("id desc")
      else
        @asks = Ask.where("id not in (?)", @rank_asks.map(&:ask_id)).order("id desc")   
      end
    end
    @categories = Category.all
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    render :layout => "empty"
  end 
  
  
  def table
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    tableModel = params[:table_name].classify.constantize
    @record_names = tableModel.columns.map(&:name)
    @records = tableModel.all.order("id desc")
    render :layout => "empty"
  end
  
  def submit_rank_ask
    ask_id = params[:ask_id]
    ranking = params[:ranking]
    category_id = params[:category_id]
    category_id = nil if category_id.blank?
    rank_ask = RankAsk.where(:ranking => ranking, :category_id => category_id).first
    if rank_ask
      rank_ask.update(:ask_id => ask_id)
    else
      RankAsk.create(:ask_id => ask_id, :ranking => ranking, :category_id => category_id)
    end 
    render :json => {:status => "success"}
  end
  
  def delete_rank_ask
    RankAsk.find(params[:rank_ask_id]).delete
    render :json => {:status => "success"}
  end
  
  def create_notice
    notice = Notice.create(:title => params[:title], :message => params[:message])
    User.where(:receive_notice_email => true).each do |user|
      UserMailer.send_notice(user, notice).deliver_now
    end
    render :json => {:status => "success"}
  end
  
end
