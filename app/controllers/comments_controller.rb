class CommentsController < ApplicationController
  before_action :set_comment, only: [:update, :destroy]

  # POST /comments.json
  def create
    if current_user
      ask = Ask.find(params[:ask_id])
      ask_deal_id = params[:is_left] == 'true' ? ask.left_ask_deal_id : ask.right_ask_deal_id

      comment = Comment.create(user_id: current_user.id,
                               ask_id: ask.id,
                               ask_deal_id: ask_deal_id,
                               content: params[:content],
                               comment_id: params[:comment_id])
      comment.generate_hash_tags
      comment = comment.as_json(include: { user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } })
      status = 'success'
    else
      status = 'not_authorized'
    end

    render json: { status: status, ask: ask, comment: comment }

    # comment_image = nil
    # if params[:image_id]
    #   preview_image = PreviewImage.find(params[:image_id])
    #   comment_image = preview_image.image unless preview_image.blank?
    # end
    #
    # comment = Comment.create(user_id: current_user.id,
    #                          ask_id: ask.id,
    #                          ask_deal_id: ask_deal_id,
    #                          content: params[:content],
    #                          comment_id: params[:comment_id],
    #                          image: comment_image)
  end

  # PUT /comments/:id.json
  def update
    comment = @comment
    if current_user && current_user.id == comment.user_id
      ask = comment.ask
      comment.update(content: params[:content])
      comment.generate_hash_tags
      comment = comment.as_json(include: { user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } })
      status = 'success'
    else
      status = 'not_authorized'
    end

    render json: { status: status, ask: ask, comment: comment }

    # comment_preview_image = PreviewImage.find_by_id(params[:image_id])
    # if comment_preview_image
    #   comment_image = comment_preview_image.image
    #   if comment_preview_image.id == params[:image_id]
    #     comment.update(content: params[:content])
    #   else
    #     comment.update(content: params[:content], image: comment_image)
    #   end
    # else
    #   if params[:image_id] == 'image_delete'
    #     comment.update(content: params[:content], image: comment_image)
    #   else
    #     comment.update(content: params[:content])
    #   end
    #   status = 'no_image'
    # end
  end

  # DELETE /comments/:id.json
  def destroy
    comment = @comment
    if current_user && comment.user_id == current_user.id
      status = 'success'
      comment.update(is_deleted: true)
      comment.generate_hash_tags
      status = 'reply_exist' unless comment.reply_comments.where(is_deleted: false).blank?
    else
      status = 'not_authorized'
    end

    render json: { status: status }
  end

  # POST /comments/:id/like.json
  def like
    comment_like = CommentLike.find_by(user_id: current_user.id,
                                       comment_id: params[:id])
    if comment_like.nil?
      already_like = false
      CommentLike.create(user_id: current_user.id, comment_id: params[:id])
      recent_user = current_user
    else
      already_like = true
      comment_like.update(is_deleted: true)
      last_comment_like = CommentLike.where(comment_id: params[:id]).last
      recent_user = last_comment_like.user unless last_comment_like.nil?
    end
    comment_like_count = CommentLike.where(comment_id: params[:id]).count

    render json: { already_like: already_like,
                   recent_user: recent_user,
                   comment_like_count: comment_like_count }
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
