class User < ActiveRecord::Base
  has_and_belongs_to_many :alrams
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable



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

end
