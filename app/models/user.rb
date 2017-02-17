class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar,
                    styles: { original: '200x200#' },
                    url: '/assets/users/:id/:style/:basename.:extension',
                    path: ':rails_root/public/assets/users/:id/:style/:basename.:extension',
                    default_url: '/images/custom/card_image_preview.png'
  validates_attachment_size :avatar, less_than: 20.megabytes
  validates_attachment_content_type :avatar, content_type: ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  before_create :rename_file
  before_update :rename_file

  include SlackNotifier
  after_create :signup_submit_notifier

  def rename_file
    return if avatar.blank?
    extension = avatar_file_name.split('.').last
    return unless %w[jpg jpeg gif png].include?(extension)
    self.avatar_file_name = "data.#{extension}"
  end

  def self.get_uniq_string_id(string_id)
    string_id = string_id.gsub(/[^0-9A-Za-z]/, '').downcase
    tmp_string_id = string_id.dup
    string_id_appendix = 0
    loop do
      user = User.find_by_string_id(tmp_string_id)
      if user
        string_id_appendix += 1
        tmp_string_id = string_id + string_id_appendix.to_s
      else
        string_id = tmp_string_id
        break
      end
    end
    string_id
  end

  def signup_submit_notifier
    user_count = User.where(user_role: 'user').count
    noti_title = ''
    noti_title += ":metal: 가입자 #{user_count.to_s.gsub(/(\d)(?=(?:\d\d\d)+(?!\d))/, '\1,')}명 돌파!!!!!\n" if (user_count % 50).zero?
    noti_title += '새로운 사용자가 회원가입하였습니다'
    noti_message = "#{gender == true ? ':mens: 남성' : ':womens: 여성'} / #{Time.now.year - birthday.year + 1}세 / #{email}"
    if sign_up_type == 'facebook'
      noti_message += "\n[#{name}님의 페이스북 프로필 보기](https://www.facebook.com/#{facebook_id})"
    elsif sign_up_type == 'email'
      noti_message += "\n이메일 가입 유저입니다"
    end
    noti_color = '#FFCC5A'
    slack_notifier(noti_title, noti_message, noti_color)
  end
  handle_asynchronously :signup_submit_notifier
end
