# coding : utf-8
class PreviewImagesController < ApplicationController

  before_filter :auth_admin, :only => ["destroy"]

  def destroy
    PreviewImage.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

  # POST /preview_images.json
  def create
    if params[:File]
      preview_image = PreviewImage.create(:user_id => current_user.id, :image => params[:File])
    elsif params[:image_url]
      # image_url = params[:image_url].gsub("?q=", "?t=470x180&q=") #원래 이미지는 thumbnail로 와서 조금 더 큰 이미지 url 생성
      # preview_image = PreviewImage.create(:user_id => current_user.id, :image => open(image_url))
      preview_image = PreviewImage.create(:user_id => current_user.id, :image => open(params[:image_url]))
    end
    image_url = preview_image.image.url(:crop) unless preview_image.image.blank? # preview로 original size 이미지를 제공하는 것이 좋으나, 모바일 디바이스에서 메모리로 인한 오류가 발생하여 최대폭 1024px로 제한
    render :json => {:image_url => image_url, :id => preview_image.id}
  end

  # POST /preview_images/crop.json
  def crop
    preview_image = PreviewImage.find(params[:preview_image_id])
    preview_image.crop_x = params[:crop_x].to_i
    preview_image.crop_y = params[:crop_y].to_i
    preview_image.crop_w = params[:crop_w].to_i
    preview_image.crop_h = params[:crop_h].to_i
    preview_image.reprocess_image
    image_url = preview_image.image.url(:crop) unless preview_image.image.blank?
    render :json => {:image_url => image_url}
  end

end
