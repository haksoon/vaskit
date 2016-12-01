# coding : utf-8
class VideosController < ApplicationController
  def get_videos
    videos = Video.all.order("id desc")
    render :json => {:videos => videos}
  end
end
