# coding : utf-8
class AskLikesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  def destroy
    AskLike.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

end
