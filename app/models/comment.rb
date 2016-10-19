class Comment < ActiveRecord::Base
  belongs_to :user

  has_attached_file :image, :styles => { :normal => "300>x" },
                    :url  => "/assets/comments/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/comments/:id/:style/:basename.:extension",
                    :default_url => "/images/custom/card_image_preview.png"
  validates_attachment_size :image, :less_than => 20.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  after_create :reload_ask_deal_comment_count
  after_update :reload_ask_deal_comment_count
  after_destroy :reload_ask_deal_comment_count

  def reload_ask_deal_comment_count
    ask = Ask.find_by_id(self.ask_id)
    if ask.left_ask_deal.id == self.ask_deal_id
      ask.left_ask_deal.update(:comment_count => Comment.where(:ask_deal_id => ask.left_ask_deal_id, :is_deleted => false).count)
    elsif ask.right_ask_deal.id == self.ask_deal_id
      ask.right_ask_deal.update(:comment_count => Comment.where(:ask_deal_id => ask.right_ask_deal_id, :is_deleted => false).count)
    end
  end

end
