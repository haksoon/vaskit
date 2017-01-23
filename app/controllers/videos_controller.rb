# coding : utf-8
class VideosController < ApplicationController

  # GET /videos.json
  def index
    videos = Video.all.order("id desc")
    render :json => {:videos => videos}
  end

end
