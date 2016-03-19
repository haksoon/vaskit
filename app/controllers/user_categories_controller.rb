# coding : utf-8
class UserCategoriesController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]
  
  def destroy
    UserCategory.find_by_id(params[:id]).delete
    redirect_to(:back)
  end
  
end
