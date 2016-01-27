# coding : utf-8
class AsksController < ApplicationController
  before_action :set_ask, only: [:show, :edit, :update, :destroy, :vote]

  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    Ask.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
  # GET /posts/new
  def new
    @ask = Ask.new
  end

  # GET /asks/1/edit
  def edit
  end
  
  # POST /asks
  # POST /asks.json
  def create
    left_deal_params = params[:left_deal]
    left_image = nil
    left_deal_is_modify = false
    
    left_preview_image = PreviewImage.find_by_id(left_deal_params[:image_id]) 
    if left_preview_image
      left_image = left_preview_image.image
    end
    
    if left_deal_params[:deal_id].blank?
      left_deal = Deal.create(:title => left_deal_params[:title], :brand => left_deal_params[:brand], :price => left_deal_params[:price], :spec1 => left_deal_params[:spec1], :spec2 => left_deal_params[:spec2], :spec3 => left_deal_params[:spec3], :image => left_image)
    else
      left_deal = Deal.find(left_deal_params[:deal_id])
      if left_image.blank?
        left_image = left_deal.image
      else
        left_deal_is_modify = true
      end
      unless left_deal.title == left_deal_params[:title] && left_deal.brand == left_deal_params[:brand] && left_deal.price == left_deal_params[:price].to_i
        left_deal_is_modify = true
      end  
    end
    
    left_ask_deal = AskDeal.create(:deal_id => left_deal.id, :user_id => current_user.id, :title => left_deal_params[:title], :brand => left_deal_params[:brand], 
                                    :price => left_deal_params[:price], :spec1 => left_deal_params[:spec1], :spec2 => left_deal_params[:spec2], :spec3 => left_deal_params[:spec3], 
                                    :image => left_image, :is_modify => left_deal_is_modify)
                                    
    right_deal_params = params[:right_deal]
    right_image = nil
    right_deal_is_modify = false
    
    right_preview_image = PreviewImage.find_by_id(right_deal_params[:image_id]) 
    if right_preview_image
      right_image = right_preview_image.image
    end
    
    if right_deal_params[:deal_id].blank?
      right_deal = Deal.create(:title => right_deal_params[:title], :brand => right_deal_params[:brand], :price => right_deal_params[:price], :spec1 => right_deal_params[:spec1], :spec2 => right_deal_params[:spec2], :spec3 => right_deal_params[:spec3], :image => right_image)
    else
      right_deal = Deal.find(right_deal_params[:deal_id])
      if right_image.blank?
        right_image = right_deal.image
      else
        right_deal_is_modify = true
      end
      unless right_deal.title == right_deal_params[:title] && right_deal.brand == right_deal_params[:brand] && right_deal.price == right_deal_params[:price].to_i
        right_deal_is_modify = true
      end  
      
    end
    
    right_ask_deal = AskDeal.create(:deal_id => right_deal.id, :user_id => current_user.id, :title => right_deal_params[:title], :brand => right_deal_params[:brand], 
                                    :price => right_deal_params[:price], :spec1 => right_deal_params[:spec1], :spec2 => right_deal_params[:spec2], :spec3 => right_deal_params[:spec3], 
                                    :image => right_image, :is_modify => right_deal_is_modify)
    
    params[:ask][:user_id] = current_user.id
    params[:ask][:left_ask_deal_id] = left_ask_deal.id
    params[:ask][:right_ask_deal_id] = right_ask_deal.id
    
    @ask = Ask.create(ask_params)
    
    redirect_to root_path
  end

  # PATCH/PUT /asks/1
  # PATCH/PUT /asks/1.json
  def update
    @ask.update(ask_params)
    
    redirect_to "/asks/#{@ask.id}"
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
      params.require(:ask).permit(:user_id, :left_ask_deal_id, :right_ask_deal_id, :category_id, :message, :be_completed, :admin_choice)
    end
end

