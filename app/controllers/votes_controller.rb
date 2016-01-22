# coding : utf-8
class VotesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    Vote.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
