class Admin::MailsController < Admin::HomeController
  # GET /admin/mails
  def index
    @mails = Notice.page(params[:page]).per(10).order(id: :desc)
  end

  # GET /admin/mails/:id
  def show
    @mail = Notice.find(params[:id])
  end

  # GET /admin/mails/new
  def new
  end

  # GET /admin/mail/target
  def target
  end

  # GET /admin/mail/template
  def template
  end

  # POST /admin/mail/test
  def test
    return if params[:title].blank? || params[:message].blank?
    notice = Notice.new(title: params[:title], message: params[:message].html_safe)
    user = User.new(email: 'notice@vaskit.kr')
    UserMailer.notice_email(user, notice).deliver_now
  end

  # POST /admin/mails
  def create
    if params[:title].blank? || params[:target].blank? || params[:message].blank?
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :new and return
    end

    if params[:target] == 'all'
      target_users = User.where.not(email: nil).where(user_role: 'user', receive_notice_email: true)
    elsif params[:target] == 'filter'
      target_users = User.where.not(email: nil).where(user_role: 'user', receive_notice_email: true)

      unless params[:filter_gender].nil?
        if params[:filter_gender].length == 1 && params[:filter_gender][0] == 'male'
          target_users = target_users.where(gender: true)
        elsif params[:filter_gender].length == 1 && params[:filter_gender][0] == 'female'
          target_users = target_users.where(gender: false)
        end
      end

      unless params[:filter_age].nil?
        if params[:filter_age].length > 0 && params[:filter_age].length < 7
          age_filter = []
          age_20 = Date.new(Time.now.year - 18, 1, 1)
          age_20_1_end = Date.new(Time.now.year - 22, 1, 1)
          age_20_2_end = Date.new(Time.now.year - 25, 1, 1)
          age_30 = Date.new(Time.now.year - 28, 1, 1)
          age_30_1_end = Date.new(Time.now.year - 32, 1, 1)
          age_30_2_end = Date.new(Time.now.year - 35, 1, 1)
          age_30_3_end = Date.new(Time.now.year - 38, 1, 1)
          params[:filter_age].each do |age|
            age_filter << "users.birthday < '#{age_20}' AND users.birthday > '#{age_20_1_end}'" if age == 'early_20'
            age_filter << "users.birthday < '#{age_20_1_end}' AND users.birthday > '#{age_20_2_end}'" if age == 'middle_20'
            age_filter << "users.birthday < '#{age_20_2_end}' AND users.birthday > '#{age_30}'" if age == 'latter_20'
            age_filter << "users.birthday < '#{age_30}' AND users.birthday > '#{age_30_1_end}'" if age == 'early_30'
            age_filter << "users.birthday < '#{age_30_1_end}' AND users.birthday > '#{age_30_2_end}'" if age == 'middle_30'
            age_filter << "users.birthday < '#{age_30_2_end}' AND users.birthday > '#{age_30_3_end}'" if age == 'latter_30'
            age_filter << "users.birthday IS NULL OR (users.birthday > '#{age_20}' OR users.birthday < '#{age_30_3_end}')" if age == 'etc'
          end
          target_users = target_users.where(age_filter.join(' OR '))
        end
      end

      ios_checked = true
      aos_checked = true
      if !params[:filter_device].nil? && params[:filter_device].length == 1
        ios_checked = false
        aos_checked = false
        params[:filter_device].each do |device|
          ios_checked = true if device == 'ios'
          aos_checked = true if device == 'aos'
        end
      end
    elsif params[:target] == 'user'
      target_users = User.where(email: params[:target_user_email])
    end

    notice = Notice.create(title: params[:title], message: params[:message].html_safe)
    target_users.each do |user|
      UserMailer.delay.notice_email(user, notice)
    end

    flash['success'] = "총 #{target_users.count}개의 메일을 성공적으로 전송하였습니다"
    redirect_to admin_mails_path
  end
end
