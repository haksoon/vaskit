# encoding: utf-8
require "#{File.dirname(__FILE__)}/../../config/environment.rb"

categories = ['IT·전자기기','패션의류·잡화','뷰티·화장품','레저·아웃도어','건강·피트니스','리빙·인테리어','자동차','맛집·모임·데이트','문화생활','여행·체험','커리어·자기개발','반려·애완동물']

categories.each do |category|
  Category.create(:name => category)
end
