class AskTmpsController < ApplicationController
  # POST /ask_tmps.json
  def create
    left_deal_params = params[:left_deal]
    right_deal_params = params[:right_deal]

    left_deal_params = {} if left_deal_params.nil?
    right_deal_params = {} if right_deal_params.nil?

    left_deal_params[:price] = left_deal_params[:price].sub(/^[0]*/, '').delete(',').to_i if !left_deal_params.nil? && !left_deal_params[:price].nil?
    right_deal_params[:price] = right_deal_params[:price].sub(/^[0]*/, '').delete(',').to_i if !right_deal_params.nil? && !right_deal_params[:price].nil?

    left_ask_deal = AskDealTmp.create(title: left_deal_params[:title],
                                      brand: left_deal_params[:brand],
                                      price: left_deal_params[:price],
                                      link: left_deal_params[:link],
                                      spec1: left_deal_params[:spec1],
                                      spec2: left_deal_params[:spec2],
                                      spec3: left_deal_params[:spec3],
                                      preview_image_id: left_deal_params[:image_id])

    right_ask_deal = AskDealTmp.create(title: right_deal_params[:title],
                                       brand: right_deal_params[:brand],
                                       price: right_deal_params[:price],
                                       link: right_deal_params[:link],
                                       spec1: right_deal_params[:spec1],
                                       spec2: right_deal_params[:spec2],
                                       spec3: right_deal_params[:spec3],
                                       preview_image_id: right_deal_params[:image_id])

    # ask
    params[:ask] = {} if params[:ask].nil?
    params[:ask][:user_id] = current_user.id
    params[:ask][:left_ask_deal_id] = left_ask_deal.id
    params[:ask][:right_ask_deal_id] = right_ask_deal.id
    params[:ask][:message].gsub!(/\S#\S/) { |message| message.gsub('#', ' #') } unless params[:ask][:message].nil? # 해시태그 띄어쓰기 해줌
    AskTmp.create(ask_params)

    render json: { status: 'success' }
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def ask_params
    params.require(:ask)
          .permit(:user_id,
                  :left_ask_deal_id,
                  :right_ask_deal_id,
                  :message,
                  :spec1,
                  :spec2,
                  :spec3)
  end
end
