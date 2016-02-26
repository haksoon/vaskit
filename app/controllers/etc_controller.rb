# coding : utf-8
class EtcController < ApplicationController
  
  def rending
  end 
  
  def access_term
  end
  
  def personal_information
  end
  
  
  def user
    @my_ask_count = Ask.where(:user_id => current_user.id).count
    @my_vote_count = Vote.where(:user_id => current_user.id).count
    @my_comment_count = Comment.where(:user_id => current_user.id).count
    
    @in_progress_count = Ask.where(:user_id => current_user.id, :be_completed => false).count
    @alram_count = Alram.where(:user_id => current_user.id, :is_read => false).count
  end
  
end
