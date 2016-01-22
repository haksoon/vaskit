# coding : utf-8
class PreviewImagesController < ApplicationController
  
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    PreviewImage.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
  # POST /preview_images.json
  def create
    preview_image = PreviewImage.create(:user_id => current_user.id, :image => params[:File])
    image_url = preview_image.image.url(:normal) unless preview_image.image.blank?
    respond_to do |format|
      format.json { render json: { "image_url"=> image_url, :id => preview_image.id } }
    end
  end
end