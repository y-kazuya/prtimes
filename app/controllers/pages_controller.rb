class PagesController < ApplicationController

  def index

  end

  def summary
    #期間は3ヶ月
    ekimei = "新宿"
    category = 1
    kyroi = 3

    #今日から3ヶ月前までのPRを取得
    today = Date.today
    from = Time.current.ago(3.month).to_s.split(" ")[0]

    @result = []

    3.times do |n|
      uri = URI.parse("https://9b199e13.prtimes.tech/date_period/#{from}/#{today}/#{n + 1}")

      @a =
      json = Net::HTTP.get(uri) #NET::HTTPを利用してAPIを叩く
      @a = JSON.parse(json)["data"].each do |pr|
        @result << pr
      end
    end


    @result


    # https://9b199e13.prtimes.tech/date_period/2019-01-22/2019-05-30/111 期間絞り　半年で 1000Pくらい

  end
end
