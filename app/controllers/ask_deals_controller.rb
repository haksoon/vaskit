# coding : utf-8
class AskDealsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    AskDeal.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
