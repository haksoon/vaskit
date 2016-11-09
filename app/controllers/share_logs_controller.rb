# coding : utf-8
class ShareLogsController < ApplicationController

  # POST /share_logs.josn
  def create
    user_id = current_user ? current_user.id : nil
    ShareLog.create(:user_id => user_id, :channel => params[:channel], :ask_id => params[:ask_id])
    render :json => { :status => "success"}
  end

end
