module Admin::ApplicationHelper
  def bootstrap_for(flash_type)
    case flash_type
    when 'success'
      type = 'alert-success'   # 초록색
      exclamation = '성공!'
    when 'error'
      type = 'alert-danger'    # 빨간색
      exclamation = '에러!'
    when 'warning'
      type = 'alert-warning'   # 노랑색
      exclamation = '경고!'
    when 'info'
      type = 'alert-info'      # 파랑색
      exclamation = '안내:'
    else
      type = flash_type.to_s
      exclamation = ''
    end
    results = { type: type,
                exclamation: exclamation }
  end

  def tagging_keywords(string)
    return string if string.nil?
    hash_tags = string.scan(/#[0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]+/)
    return string if hash_tags.nil?
    hash_tags.sort.reverse.each do |hash_tag|
      hash_tag = hash_tag.delete(',')
      keyword = hash_tag.delete('#').delete('?')
      string = highlight(string,
                         hash_tag,
                         highlighter: "<a href='#{CONFIG["host"]}/search?type=hash_tag&keyword=#{keyword}' target='_blank' class='hash_tag'>#{hash_tag}</a>")
    end
    string.gsub(/\r?\n/, '<br>')
  end

  def format_datetime(datetime, type = :datetime)
    return '' unless datetime
    case type
    when :datetime
      format = '%Y-%m-%d %H:%M:%S'
      return datetime.strftime(format)
    when :date
      format = '%Y-%m-%d'
      return datetime.strftime(format)
    when :time
      format = '%H:%M:%S'
      return datetime.strftime(format)
    when 'past'
      month = ((Time.now - datetime.to_time) / 1.month).to_i
      day = ((Time.now - datetime.to_time) / 1.day).to_i
      hour = ((Time.now - datetime.to_time) / 1.hour).to_i
      minutes = ((Time.now - datetime.to_time) / 1.minutes).to_i

      tag =
        if month.nonzero?
          month.to_s + '개월 전'
        elsif day.nonzero?
          day.to_s + '일 전'
        elsif hour.nonzero?
          hour.to_s + '시간 전'
        elsif minutes > 5
          minutes.to_s + '분 전'
        else
          '방금 전'
        end
      return tag.html_safe
    end
  end
end
