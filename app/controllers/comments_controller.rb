# coding : utf-8
class CommentsController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  def create
    ask_id = params[:ask_id]
    ask_deal_id = params[:ask_deal_id]
    content = params[:content]
    comment_id = params[:comment_id] #AJS추가
    comment_image = nil

    comment_preview_image = PreviewImage.find_by_id(params[:image_id])
    if comment_preview_image
      comment_image = comment_preview_image.image
    end

    if current_user
      comment = Comment.create(:user_id => current_user.id, :ask_id => ask_id, :ask_deal_id => ask_deal_id, :content => content, :comment_id => comment_id, :image => comment_image)

      ask = Ask.find(ask_id)
      if comment_id == nil
        if ask.user_id != comment.user_id
          alram = Alram.where(:user_id => ask.user_id, :ask_id => ask.id).where("alram_type like ?", "comment_%").first
          if alram
            alram.update(:is_read => false, :send_user_id => current_user.id, :alram_type => "comment_" + Comment.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s  )
          else
            Alram.create(:user_id => ask.user_id, :send_user_id => current_user.id, :ask_id => ask.id, :alram_type => "comment_" + Comment.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s )
          end
        end

        #과거에 달았던 애가 있는지 체크
        sub_comment_user_ids = Comment.where("ask_id = ? AND id < ?",  ask.id, comment.id ).pluck(:user_id).uniq
        sub_comment_user_ids.each_with_index do |sub_comment_user_id|
          if sub_comment_user_id != ask.user_id && comment.user_id != sub_comment_user_id
            sub_comment = Comment.where(:ask_id => ask.id, :user_id => sub_comment_user_id).first
            user_count = Comment.where("ask_id = ? AND id > ? AND user_id <> ?",  ask.id, sub_comment.id, sub_comment.user_id ).count
            alram = Alram.where(:user_id => sub_comment.user_id, :ask_owner_user_id => ask.user_id, :ask_id => ask.id).where("alram_type like ?", "sub_comment_%").first
            if alram
              alram.update(:is_read => false, :send_user_id => comment.user_id, :alram_type => "sub_comment_" + user_count.to_s )
            else
              Alram.create(:user_id => sub_comment.user_id, :send_user_id => comment.user_id, :ask_owner_user_id => ask.user_id, :ask_id => ask.id, :alram_type => "sub_comment_" + user_count.to_s )
            end
          end
        end

      #대댓글의 경우 알람 별도로 추가
      elsif comment_id != nil
        original_comment = Comment.find(comment_id)
        if original_comment.user_id != comment.user_id
          alram = Alram.where(:user_id => original_comment.user_id, :ask_id => ask.id).where("alram_type like ?", "reply_comment_%").first
          if alram
            alram.update(:is_read => false, :send_user_id => current_user.id, :alram_type => "reply_comment_" + Comment.where("comment_id = ?", comment.comment_id).count.to_s  )
          else
            Alram.create(:user_id => original_comment.user_id, :send_user_id => current_user.id, :ask_id => ask.id, :alram_type => "reply_comment_" + Comment.where("comment_id = ?", comment.comment_id).count.to_s )
          end
        end
      end

      message = "success"
    else
      message = "not_user"
    end
    comment = comment.as_json(:include => [:user])
    ask = ask.as_json(:include => [:comments])
    render :json => {:message => message, :comment => comment, :ask => ask}
  end

  #어드민에서 삭제
  def destroy
    Comment.find_by_id(params[:id]).destroy
    redirect_to(:back)
  end

  def comment_del
    comment = Comment.find_by_id(params[:id])
    if comment.user_id == current_user.id
      comment.update(:is_deleted => 1)
      if Comment.where(:comment_id => params[:id]).blank?
        status = "success"
      else
        status = "reply_exist"
      end
    end
    render :json => {:status => status, :comment => comment}
  end


  def update
    comment = Comment.find_by_id(params[:id])
    comment_preview_image = PreviewImage.find_by_id(params[:image_id])
    status = "success"
    if comment_preview_image
      comment_image = comment_preview_image.image
      if comment_preview_image.id == params[:image_id]
        comment.update(:content => params[:content])
      else
        comment.update(:content => params[:content], :image => comment_image)
      end
    else
      if params[:image_id] == "image_delete"
        comment.update(:content => params[:content], :image => comment_image)
      else
        comment.update(:content => params[:content])
      end
      status = "no_image"
    end
    render :json => {:status => status, :comment => comment}
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
      comment_like = CommentLike.create(:user_id => current_user.id, :comment_id => params[:id])
      comment.update(:like_count => comment.like_count + 1)

      if comment.user_id != comment_like.user_id && Alram.where(:user_id => comment.user_id, :send_user_id => current_user.id, :ask_id => comment.ask_id).blank?
        alram = Alram.where(:user_id => comment.user_id, :ask_id => comment.ask_id).where("alram_type like ?", "like_comment_%").first
        if alram
          alram.update(:is_read => false, :send_user_id => current_user.id, :alram_type => "like_comment_" + CommentLike.where("comment_id = ? AND user_id <> ?", comment.id, comment.user_id).count.to_s )
        else
          Alram.create(:user_id => comment.user_id, :send_user_id => current_user.id, :ask_id => comment.ask_id, :alram_type => "like_comment_" + CommentLike.where("comment_id = ? AND user_id <> ?", comment.id, comment.user_id).count.to_s )
        end
      end
    end
    render :json => {:already_like => already_like, :comment_like => comment_like}
  end

end
