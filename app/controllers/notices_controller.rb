# coding : utf-8
class NoticesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  def destroy
    Notice.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

end
