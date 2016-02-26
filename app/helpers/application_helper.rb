module ApplicationHelper
  
  def get_past_time(created_at)
    tag = ""
    
    month = ((Time.now - created_at.to_time)/1.month).to_i
    if month != 0
      tag = month.to_s + "개월 전"
      return tag.html_safe
    end
    
    day = ((Time.now - created_at.to_time)/1.day).to_i
    if day != 0
      tag = day.to_s + "일 전"
      return tag.html_safe
    end
    
    hour = ((Time.now - created_at.to_time)/1.hour).to_i
    if hour != 0
      tag = hour.to_s + "시간 전"
      return tag.html_safe
    elsif hour == -1
      tag = "방금 전"
      return tag.html_safe
    end
    
    minutes = ((Time.now - created_at.to_time)/1.minutes).to_i
    if minutes > 5
      tag =  minutes.to_s + "분 전"
      return tag.html_safe
    else
      tag = "방금 전"
      return tag.html_safe
    end
  end
  
end
