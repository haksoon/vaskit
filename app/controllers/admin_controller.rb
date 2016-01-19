# coding : utf-8
class AdminController < ApplicationController
  before_action :is_admin
  
  def is_admin
    render  :template => "/admin/not_auth" unless current_user.email == "admin@vaskit.com" 
  end
  
  def index
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    render :layout => false
  end 
  
  
  def table
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    tableModel = params[:table_name].classify.constantize
    @record_names = tableModel.columns.map(&:name)
    @records = tableModel.all.order("id desc")
    render :layout => false
  end
  
end
