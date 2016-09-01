# coding : utf-8
class ReportsController < ApplicationController

  #POST /reports.json
  def create
    already_report = true
    if Report.where(:target => params[:target], :target_id => params[:target_id], :user_id => current_user.id ).blank?
      already_report = false
      report = Report.create(:target => params[:target], :target_id => params[:target_id], :report_type => params[:report_type], :message => params[:message], :user_id => current_user.id )
      AdminMailer.delay.report_submitted(report)
    end

    render :json => {:already_report => already_report}
  end


end
