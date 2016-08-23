# coding : utf-8
class InquiryController < ApplicationController
  before_filter :auth_admin, :only => ["destroy"]

  def destroy
    Inquiry.find_by_id(params[:id]).delete
    redirect_to(:back)
  end

end
