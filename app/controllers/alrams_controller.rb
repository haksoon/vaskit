# coding : utf-8
class AlramsController < ApplicationController

  # def index
  #   @alrams = Alram.where(:user_id => current_user.id).order("updated_at desc").limit(15)
  # end

  #AJS추가
  def read
    ask = Ask.find_by_id(params[:ask_id]).as_json(:include => [:category, :user, :left_ask_deal, :right_ask_deal, :ask_complete, {:comments => {:include => :user}} ])
    Alram.where(:id => params[:id], :is_read => false).each do |alram|
      alram.record_timestamps = false #updated_at 안바뀌게
      alram.update(:is_read => true)
      alram.record_timestamps = true #updated_at 안바뀌게
    end
    render :json => {:status => "success", :ask => ask}
  end

  def all_read
    Alram.where(:user_id => current_user.id, :is_read => false).each do |alram|
      alram.record_timestamps = false #updated_at 안바뀌게
      alram.update(:is_read => true)
      alram.record_timestamps = true #updated_at 안바뀌게
    end
    render :json => {:status => "success"}
  end

end
