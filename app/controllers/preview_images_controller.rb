class PreviewImagesController < ApplicationController
  # GET /preview_images/:id.json
  def show
    preview_image_url = PreviewImage.find(params[:id]).image.url(:crop)
    render json: { preview_image_url: preview_image_url }
  end

  # POST /preview_images.json
  def create
    image =
      if params[:File]
        params[:File]
      elsif params[:image_url]
        open(params[:image_url])
      end
    preview_image = PreviewImage.create(user_id: current_user.id, image: image)
    # preview로 original size 이미지를 제공하는 것이 좋으나, 모바일 디바이스에서 메모리로 인한 오류가 발생하여 최대폭 1024px로 제한
    image_url = preview_image.image.url(:square) unless preview_image.image.blank?
    render json: { image_url: image_url, preview_img_id: preview_image.id }
  end

  # PUT /preview_images/:id.json
  def update
    preview_image = PreviewImage.find(params[:id])
    preview_image.crop_x = params[:crop_x].to_i
    preview_image.crop_y = params[:crop_y].to_i
    preview_image.crop_w = params[:crop_w].to_i
    preview_image.crop_h = params[:crop_h].to_i
    preview_image.reprocess_image

    if params[:cropping_type] == 'user_profile'
      user = User.find(current_user.id)
      user.update(avatar: preview_image.image.styles[:square])
      image_url = user.avatar.url(:original)
    else
      image_url = preview_image.image.url(:square)
    end

    render json: { image_url: image_url }
  end
end
