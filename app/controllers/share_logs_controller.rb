# coding : utf-8
class ShareLogsController < ApplicationController

  # POST /share_logs.josn
  def create
    if current_user
      ShareLog.create(:user_id => current_user.id, :channel => params[:channel], :ask_id => params[:ask_id]) unless current_user.user_role == "admin"
    else
      ShareLog.create(:user_id => nil, :channel => params[:channel], :ask_id => params[:ask_id])
    end
    render :json => { :status => "success"}
  end

end
