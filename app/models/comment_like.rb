class CommentLike < ActiveRecord::Base
  after_create :reload_comment_like_count
  after_update :reload_comment_like_count
  after_destroy :reload_comment_like_count

  def reload_comment_like_count
    comment = Comment.find_by_id(self.comment_id)
    comment.update(:like_count => CommentLike.where(:comment_id => self.comment_id).count)

    comment_like_count = CommentLike.where(:comment_id => self.comment_id).where.not(:user_id => comment.user_id).count

    if comment.user_id != self.user_id
      if User.find_by_id(comment.user_id).alram_4 == true #알림 옵션 체크
        alram = Alram.where(:user_id => comment.user_id, :comment_id => comment.id).where("alram_type like ?", "like_comment_%").first
        if alram
          alram_count = alram.alram_type.gsub("like_comment_","").to_i
          if alram_count < comment_like_count
            alram.update(:is_read => false, :send_user_id => self.user_id, :alram_type => "like_comment_"+comment_like_count.to_s)
          end
        else
          Alram.create(:user_id => comment.user_id, :send_user_id => self.user_id, :ask_id => comment.ask_id, :comment_id => comment.id, :alram_type => "like_comment_"+comment_like_count.to_s)
        end
      end
    end
  end

end
