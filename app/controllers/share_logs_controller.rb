# coding : utf-8
class ShareLogsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    MailLog.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
