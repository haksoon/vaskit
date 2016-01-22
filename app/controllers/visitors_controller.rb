# coding : utf-8
class VisitorController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    Visitor.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
