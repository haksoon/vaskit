# coding : utf-8
class CommentsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def create
    ask_id = params[:ask_id]
    ask_deal_id = params[:ask_deal_id]
    content = params[:content]
    message = "success"
    if current_user
      comment = Comment.create(:user_id => current_user.id, :ask_id => ask_id, :ask_deal_id => ask_deal_id, :content => content)
    else
      message = "not_user"
    end
    comment = comment.as_json(:include => [:user])
    render :json => {:message => message, :comment => comment}
  end
  
  
  def destroy
    Comment.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
  def like
    already_like = false
    comment = Comment.find(params[:id])
    comment_like = CommentLike.where(:user_id => current_user.id, :comment_id => params[:id]).first
    if comment_like
      already_like = true
      comment_like.delete
      comment.update(:like_count => comment.like_count - 1)
    else  
      CommentLike.create(:user_id => current_user.id, :comment_id => params[:id])
      comment.update(:like_count => comment.like_count + 1)
    end
    render :json => {:already_like => already_like}
  end
  
end
