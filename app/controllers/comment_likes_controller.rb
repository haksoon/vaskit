# coding : utf-8
class CommentLikesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  def destroy
    CommentLike.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

end
