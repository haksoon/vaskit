# coding : utf-8
class Admin::HomeController < ApplicationController
  before_action :auth_admin

  # GET /admin
  def index
    render :layout => "layout_admin", :template => "/admin/index"
  end

  protected
  def auth_admin
    render :layout => "layout_template", :template => "/admin/not_auth" unless current_user && current_user.user_role == "admin"
  end

end
