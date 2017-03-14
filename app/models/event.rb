class Event < ActiveRecord::Base
  belongs_to :ask

  has_attached_file :image,
                    url: '/assets/events/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/events/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :image, less_than: 20.megabytes
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  validates :title, presence: true
  validates :description, presence: true
  validates :ask_id, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :image, presence: true

  before_create :rename_file
  before_update :rename_file

  def rename_file
    return if image.blank?
    extension = image_file_name.split('.').last
    return unless %w[jpg jpeg gif png].include?(extension)
    self.image_file_name = "event.#{extension}"
  end
end
