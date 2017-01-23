# coding : utf-8
class ShareLogsController < ApplicationController
  # skip_before_action :verify_authenticity_token, only: [:create]

  # POST /share_logs.json
  def create
    if current_user
      ShareLog.create(user_id: current_user.id, channel: params[:channel], ask_id: params[:ask_id], collection_id: params[:collection_id]) #unless current_user.user_role == "admin"
    else
      ShareLog.create(user_id: nil, channel: params[:channel], ask_id: params[:ask_id], collection_id: params[:collection_id])
    end
    render json: {}
  end

end
