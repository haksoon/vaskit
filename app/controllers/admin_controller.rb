# coding : utf-8
class AdminController < ApplicationController
  before_filter :auth_admin
  
  def index
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    render :layout => "empty"
  end 
  
  
  def table
    @tables = ActiveRecord::Base.connection.tables
    @tables = @tables - ["schema_migrations"]
    tableModel = params[:table_name].classify.constantize
    @record_names = tableModel.columns.map(&:name)
    @records = tableModel.all.order("id desc")
    render :layout => "empty"
  end
  
end
