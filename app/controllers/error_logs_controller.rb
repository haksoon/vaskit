# coding : utf-8
class ErrorLogsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  def error_report
    obj = params[:obj]
    href = params[:href]
    ua = request.headers['User-Agent'] ? request.headers['User-Agent'] : "unknown"
    msg = params[:msg]
    url = params[:url]
    line = params[:line]
    col = params[:col]
    if current_user
      log = ErrorLog.create(:user_id => current_user.id, :error => obj, :error_href => href, :user_agent => ua, :error_message => msg, :error_url => url, :error_line => line, :error_col => col)
    else
      log = ErrorLog.create(:visitor_id => @visitor.id, :error => obj, :error_href => href, :user_agent => ua, :error_message => msg, :error_url => url, :error_line => line, :error_col => col)
    end
    AdminMailer.delay.client_error(log) if Rails.env == "production"
    render :json => {:status => "success"}
  end

  def destroy
    ErrorLog.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

end
