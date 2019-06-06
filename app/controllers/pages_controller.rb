class PagesController < ApplicationController

  def index

  end

  def summary
    ekimei = "新宿"
    category = 1
    kyroi = 3


    aaa = 3
    uri = URI.parse("https://9b199e13.prtimes.tech/main_category_release/001/4")
    json = Net::HTTP.get(uri) #NET::HTTPを利用してAPIを叩く
    @result = JSON.parse(json) #返ってきたjsonデータをrubyの配列に変換


  end
end
