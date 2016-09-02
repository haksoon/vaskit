# coding : utf-8
class ShareLogsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  skip_before_action :verify_authenticity_token, :only => ["create"]

  # POST /share_logs.josn
  def create
    if current_user
      ShareLog.create(:user_id => current_user.id, :channel => params[:channel], :ask_id => params[:ask_id])
    end
    render :json => { :status => "success"}
  end

  def destroy
    ShareLog.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

end
