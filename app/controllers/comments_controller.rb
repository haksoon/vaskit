# coding : utf-8
class CommentsController < ApplicationController

  # POST /comments.json
  def create
    content = params[:content]
    original_comment_id = params[:comment_id]

    ask = Ask.find(params[:ask_id])
    ask_deal_id = params[:is_left] == "true" ? ask.left_ask_deal_id : ask.right_ask_deal_id

    comment_image = nil
    if params[:image_id]
      comment_preview_image = PreviewImage.find(params[:image_id])
      comment_image = comment_preview_image.image unless comment_preview_image.blank?
    end

    if current_user
      comment = Comment.create(user_id: current_user.id, ask_id: ask.id, ask_deal_id: ask_deal_id, content: content, comment_id: original_comment_id, image: comment_image)
      status = "success"
    else
      status = "not_authorized"
    end

    comment = comment.as_json(include: [:user])

    render json: {status: status, ask: ask, comment: comment}
  end

  # PUT /comments/:id.json
  def update
    content = params[:content]
    update_comment_id = params[:comment_id]

    comment = Comment.find(update_comment_id)

    if current_user && current_user.id == comment.user_id
      comment.update(content: content)
      ask = Ask.find(comment.ask_id)
      comment = comment.as_json(include: [:user])
      status = "success"
    else
      status = "not_authorized"
    end

    render json: {status: status, ask: ask, comment: comment}

    # comment = Comment.find_by_id(params[:id])
    # comment_preview_image = PreviewImage.find_by_id(params[:image_id])
    # status = "success"
    # if comment_preview_image
    #   comment_image = comment_preview_image.image
    #   if comment_preview_image.id == params[:image_id]
    #     comment.update(content: params[:content])
    #   else
    #     comment.update(content: params[:content], image: comment_image)
    #   end
    # else
    #   if params[:image_id] == "image_delete"
    #     comment.update(content: params[:content], image: comment_image)
    #   else
    #     comment.update(content: params[:content])
    #   end
    #   status = "no_image"
    # end
    # render :json => {status: status, comment: comment}
  end

  # DELETE /comments/:id.json
  def destroy
    comment = Comment.find(params[:id])
    if current_user && comment.user_id == current_user.id
      comment.update(is_deleted: 1)
      if Comment.where(comment_id: params[:id]).blank?
        status = "success"
      else
        status = "reply_exist"
      end
    else
      status = "not_authorized"
    end
    render json: {status: status}
  end

  # POST /comments/:id/like.json
  def like
    comment = Comment.find(params[:id])
    already_like = false
    comment_like = CommentLike.where(user_id: current_user.id, comment_id: params[:id]).first
    if comment_like
      already_like = true
      comment_like.destroy
    else
      comment_like = CommentLike.create(user_id: current_user.id, comment_id: params[:id])
    end
    render json: {already_like: already_like, comment_like: comment_like}
  end

end
