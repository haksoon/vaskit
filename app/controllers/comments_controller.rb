class CommentsController < ApplicationController
  before_action :set_comment, only: [:update, :destroy]

  # GET /comments.json
  def index
    ask = Ask.find(params[:ask_id])
    comments =
      ask.original_comments
         .where('created_at < ?', params[:date].to_datetime)
         .order(like_count: :desc, id: :desc)
         .page(params[:page].to_i)
         .per(Comment::COMMENT_PER)
    is_more_load = comments.total_pages > params[:page].to_i
    comments =
      comments
      .as_json(include: [{ user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } },
                         { comment_likes: { include: { user: { only: [:id, :string_id] } } } },
                         { reply_comments: { include: [{ user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } },
                                                       { comment_likes: { include: { user: { only: [:id, :string_id] } } } }] } }])

    render json: { ask: ask, comments: comments, is_more_load: is_more_load }
  end

  # POST /comments.json
  def create
    content = params[:content]
    original_comment_id = params[:comment_id]
    if current_user
      ask = Ask.find(params[:ask_id])
      ask_deal_id = params[:is_left] == 'true' ? ask.left_ask_deal_id : ask.right_ask_deal_id

      comment = Comment.create(user_id: current_user.id,
                               ask_id: ask.id,
                               ask_deal_id: ask_deal_id,
                               content: content,
                               comment_id: original_comment_id)

      comment.generate_hash_tags
      comment = comment.as_json(include: [{ user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } },
                                          { comment_likes: { include: { user: { only: [:id, :string_id] } } } }])
      status = 'success'
      
      if current_user.id != ask.user_id
        if content.length < 50
          UserActivityScore.update_user_grade(current_user.id, "comment")
        elsif content.length < 100
          UserActivityScore.update_user_grade(current_user.id, "comment_50")
        else
          UserActivityScore.update_user_grade(current_user.id, "comment_100")
        end
      end
      if original_comment_id
        original_comment_user_id = Comment.find_by_id(original_comment_id).user_id
        if original_comment_user_id != current_user.id && original_comment_user_id != ask.user_id
          UserActivityScore.update_user_grade(original_comment_user_id, "original_comment")
        end
      end
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
      if current_user.id != ASK.find_by_id(comment.ask_id).user_id
        if comment.content.length < 50
          UserActivityScore.update_user_grade(current_user.id, "comment_deleted")
        elsif content.length < 100
          UserActivityScore.update_user_grade(current_user.id, "comment_50_deleted")
        else
          UserActivityScore.update_user_grade(current_user.id, "comment_100_deleted")
        end
        if content.length < 50
          UserActivityScore.update_user_grade(current_user.id, "comment")
        elsif length < 100
          UserActivityScore.update_user_grade(current_user.id, "comment_50")
        else
          UserActivityScore.update_user_grade(current_user.id, "comment_100")
        end
      end
      ask = comment.ask
      comment.update(content: params[:content])
      comment.generate_hash_tags
      comment = comment.as_json(include: [{ user: { only: [:id, :string_id, :birthday, :gender, :avatar_file_name] } },
                                          { comment_likes: { include: { user: { only: [:id, :string_id] } } } }])
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
      comment.update(is_deleted: true)
      comment.update_columns(ask_deal_id: nil) if comment.reply_comments.count.zero?
      comment.original_comment.update_columns(ask_deal_id: nil) if comment.original_comment && comment.original_comment.is_deleted && comment.original_comment.reply_comments.count.zero?
      comment.generate_hash_tags
      status = 'success'

      if current_user.id != ASK.find_by_id(comment.ask_id).user_id
        if comment.content.length < 50
          UserActivityScore.update_user_grade(current_user.id, "comment_deleted")
        elsif content.length < 100
          UserActivityScore.update_user_grade(current_user.id, "comment_50_deleted")
        else
          UserActivityScore.update_user_grade(current_user.id, "comment_100_deleted")
        end
      end
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
      UserActivityScore.update_user_grade(current_user.id, "comment_like")
      UserActivityScore.update_user_grade(Comment.find_by_id(params[:id]).user_id, "original_comment_like")
    else
      already_like = true
      comment_like.update(is_deleted: true)
      last_comment_like = CommentLike.where(comment_id: params[:id]).last
      recent_user = last_comment_like.user unless last_comment_like.nil?
      UserActivityScore.update_user_grade(current_user.id, "comment_like_deleted")
      UserActivityScore.update_user_grade(Comment.find_by_id(params[:id]).user_id, "original_comment_like_deleted")
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
