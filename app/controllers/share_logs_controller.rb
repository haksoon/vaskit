# coding : utf-8
class ShareLogsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  # POST /share_logs.josn
  def create
    if current_user
      ShareLog.create(:user_id => current_user.id, :channel => params[:channel])
    end
    
    render :json => { :status => "success"}
  end
  
  
  def destroy
    MailLog.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
