# coding : utf-8
class LogReportsController < ApplicationController

  #POST /log_reports.json
  def create
    already_report = true
    if LogReport.where(target: params[:target], target_id: params[:target_id], user_id: current_user.id ).blank?
      already_report = false
      report = LogReport.create(target: params[:target], target_id: params[:target_id], report_type: params[:report_type], message: params[:message], user_id: current_user.id )
    end
    render json: {already_report: already_report}
  end

end
