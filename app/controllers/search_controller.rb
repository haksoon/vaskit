# coding : utf-8
class SearchController < ApplicationController
  
  def get_keyword
    keyword = params[:keyword]
    users = []
    hash_tags = []
    ask_deals = []
    brand = false
    
    unless keyword.blank?
      users = User.where("string_id like ?", "%#{keyword}%") 
      hash_tags = HashTag.where("keyword like ?", "%#{keyword}%")
      ask_deals = AskDeal.where("title like ?", "%#{keyword}%" )
      brand = true unless AskDeal.where("brand like ?", "%#{keyword}%" ).blank?
    end
    render :json => {:users => users, :hash_tags => hash_tags, :ask_deals => ask_deals, :brand => brand}
  end
  
end
