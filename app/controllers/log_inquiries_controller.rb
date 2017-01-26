# coding : utf-8
class LogInquiriesController < ApplicationController

  # POST /log_inquiries.json
  def create
    user_id = current_user ? current_user.id : nil
    inquiry = LogInquiry.create(user_id: user_id, message: params[:message], contact: params[:contact])
    render json: {status: "success"}
  end

end
