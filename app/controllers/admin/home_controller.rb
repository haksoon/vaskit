class Admin::HomeController < ActionController::Base
  include PushSend
  before_action :auth_admin
  layout 'layout_admin'

  # GET /admin
  def index
    render template: '/admin/index'
  end

  protected

  def auth_admin
    return if current_user && current_user.user_role == 'admin'
    render layout: 'layout_template',
           template: '/admin/not_auth'
  end
end
