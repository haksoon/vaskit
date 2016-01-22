# coding : utf-8
class CommentsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    Comment.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
