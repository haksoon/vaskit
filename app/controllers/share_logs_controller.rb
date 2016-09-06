# coding : utf-8
class ShareLogsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  # skip_before_action :verify_authenticity_token, :only => ["create"]

  # POST /share_logs.josn
  def create
    user_id = current_user ? current_user.id : nil
    ShareLog.create(:user_id => user_id, :channel => params[:channel], :ask_id => params[:ask_id])
    render :json => { :status => "success"}
  end

  def destroy
    ShareLog.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

end
