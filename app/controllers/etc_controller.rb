# coding : utf-8
class EtcController < ApplicationController

  def landing
  end

  def access_term
  end

  def privacy_policy
  end

  def inquiry
  end

  def create_inquiry
    user_id = current_user ? current_user.id : nil
    inquiry = Inquiry.create(:user_id => user_id, :message => params[:message], :contact => params[:contact])
    AdminMailer.delay.inquiry_submitted(inquiry)
    render :json => {:status => "success" }
  end

  def help
  end

  def update
  end

  def update_contact
    AdminMailer.delay.update_contact(params[:contact])
    render json: {}
  end

end
