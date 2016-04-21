# coding : utf-8
class AskCompletesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    AskComplete.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
