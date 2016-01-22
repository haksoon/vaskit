# coding : utf-8
class HashTagsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    HashTag.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
