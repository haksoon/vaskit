class Admin::RankAsksController < Admin::HomeController

  # GET /admin/rank_asks
  def index
    respond_to do |format|
      format.html {
        category_id = params[:category_id]
        if category_id
          @rank_asks = RankAsk.where(:category_id => category_id).order("ranking asc")
          if @rank_asks.blank?
            @asks = Ask.where(:category_id => category_id).page(0).per(5).order("id desc").limit(5)
          else
            @asks = Ask.where(:category_id => category_id).where("id not in (?)", @rank_asks.map(&:ask_id)).page(0).per(5).order("id desc").limit(5)
          end
          @category = Category.find(category_id)
        else
          @rank_asks = RankAsk.where(:category_id => nil).order("ranking asc")
          if @rank_asks.blank?
            @asks = Ask.all.page(0).per(5).order("id desc").limit(5)
          else
            @asks = Ask.where("id not in (?)", @rank_asks.map(&:ask_id)).page(0).per(5).order("id desc").limit(5)
          end
        end
        @categories = Category.all
        render :layout => "layout_admin"
      }
      format.json {
        category_id = params[:category_id]
        if category_id == ""
          rank_asks = RankAsk.where(:category_id => nil).order("ranking asc")
          if rank_asks.blank?
            asks = Ask.all.page(params[:page]).per(5).order("id desc")
          else
            asks = Ask.where("id not in (?)", rank_asks.map(&:ask_id)).page(params[:page]).per(5).order("id desc")
          end
        else
          rank_asks = RankAsk.where(:category_id => category_id).order("ranking asc")
          if rank_asks.blank?
            asks = Ask.where(:category_id => category_id).page(params[:page]).per(5).order("id desc")
          else
            asks = Ask.where(:category_id => category_id).where("id not in (?)", rank_asks.map(&:ask_id)).page(params[:page]).per(5).order("id desc")
          end
        end
        asks = asks.as_json(:include => [:left_ask_deal, :right_ask_deal])
        render :json => {asks: asks}
      }
    end
  end

  # POST /admin/rank_asks.json
  def create
    ask_id = params[:ask_id]
    ranking = params[:ranking]
    category_id = params[:category_id]
    category_id = nil if category_id.blank?
    ask = Ask.where(:id => ask_id)
    if ask.blank?
      status = "fail"
    else
      rank_ask = RankAsk.where(:ranking => ranking, :category_id => category_id).first
      if rank_ask
        rank_ask.update(:ask_id => ask_id)
      else
        RankAsk.create(:ask_id => ask_id, :ranking => ranking, :category_id => category_id)
      end
      status = "success"
    end
    render :json => {:status => status}
  end

  # DELETE /admin/rank_asks/:id.json
  def destroy
    RankAsk.find(params[:id]).destroy
    render :json => {:status => "success"}
  end

end
