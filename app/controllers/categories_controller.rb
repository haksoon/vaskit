# coding : utf-8
class CategoriesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    Category.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
