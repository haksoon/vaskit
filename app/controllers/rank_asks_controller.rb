# coding : utf-8
class RankAsksController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    RankAsk.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
