class Admin::NoticeController < Admin::HomeController

  # GET /admin/notice
  def index
    @notices = Notice.all.order("id desc")
    render :layout => "layout_admin"
  end

  # POST /admin/notice.json
  def create
    notice = Notice.create(:title => params[:title], :message => params[:message])
    User.where(:receive_notice_email => true).each do |user|
      UserMailer.delay.send_notice(user, notice)
    end
    render :json => {:status => "success"}
  end
end
