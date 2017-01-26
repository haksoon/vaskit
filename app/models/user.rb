class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar, :styles => { :original => "200x200#" },
                    :url  => "/assets/users/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/users/:id/:style/:basename.:extension",
                    :default_url => "/images/custom/card_image_preview.png"
  validates_attachment_size :avatar, :less_than => 20.megabytes
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  before_create :rename_file
  before_update :rename_file

  include SlackNotifier
  after_create :signup_submit_notifier

  def rename_file
    if self.avatar_file_name != nil
      if ["jpg", "jpeg", "gif", "png"].include? (self.avatar_file_name.split(".").last)
        self.avatar_file_name = "data." +  self.avatar_file_name.split(".").last
      end
    end
  end

  def self.get_uniq_string_id(string_id)
    ########################## profile의 string_id 를 unique하게 만들기 위한 string_id 찾기
    string_id = string_id.gsub(/[^0-9A-Za-z]/, '').downcase # 특수문자 제거 및 소문자화

    tmp_string_id = string_id.dup
    string_id_appendix = 0
    while(true)
      user = User.find_by_string_id(tmp_string_id)
      if user
        string_id_appendix = string_id_appendix + 1
        tmp_string_id = tmp_string_id + string_id_appendix.to_s
      else
        string_id = tmp_string_id
        break
      end
    end
    tmp_string_id
    ###########################
  end

  def signup_submit_notifier
    noti_title = "새로운 사용자가 회원가입하였습니다"
    noti_gender = self.gender == true ? "남성" : "여성"
    noti_message = "- 가입방식: " + self.sign_up_type.to_s + "\n- 이메일: " + self.email.to_s + "\n- 성별: " + noti_gender.to_s + "\n- 생년월일: " + self.birthday.to_s
    noti_color = "#FF7200"
    slack_notifier(noti_title, noti_message, noti_color)
  end
  handle_asynchronously :signup_submit_notifier

end
