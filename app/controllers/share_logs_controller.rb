class ShareLogsController < ApplicationController
  # POST /share_logs.json
  def create
    user_id = current_user ? current_user.id : nil
    ShareLog.create(user_id: user_id,
                    channel: params[:channel],
                    ask_id: params[:ask_id],
                    collection_id: params[:collection_id])
    render json: {}
  end
end
