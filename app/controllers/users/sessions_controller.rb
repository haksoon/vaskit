# -*- coding: utf-8 -*-
class Users::SessionsController < Devise::SessionsController
  skip_before_filter :auth_user
  
  
  def check_email
    is_new_email = true
    user = User.find_by_email(params[:email])
    
    is_new_email = false if user
    render :json => {:is_new_email => is_new_email}
  end
  
end

