class PagesController < ApplicationController
  API_KEY = "AIzaSyAu--Z2zo37olt65ga_kQ2rJLBzNT_u6Ys"

  def index

  end

  def summary
    #期間は3ヶ月
    ekimei = "新宿"
    category = 2
    kyroi = 3

    #今日から3ヶ月前までのPRを取得
    today = Date.today
    from = Time.current.ago(3.month).to_s.split(" ")[0]

    @result = []

    3.times do |n|
      uri = URI.parse("https://9b199e13.prtimes.tech/date_period/#{from}/#{today}/#{n + 1}")
      json = Net::HTTP.get(uri) #NET::HTTPを利用してAPIを叩く


      JSON.parse(json)["data"].each do |pr|

        url = URI.parse("https://9b199e13.prtimes.tech/detail/#{pr['company_id'].to_i}/#{pr['release_id'].to_i}/")
        json = Net::HTTP.get(url)
        if (JSON.parse(json)["data"]["address"] != [] || JSON.parse(json)["data"]["address"][0] != nil)  && JSON.parse(json)["data"]["main_category_id"] == category
          @result << JSON.parse(json)["data"]
        end
      end
    end #@result 期間（三ヶ月以内と、住所があるかどうか、カテゴリー一致してるかどうかで絞ってる


    @finish = []

    @result.each do |pr|
      if pr["address"][0] != nil

        address = pr["address"][0].gsub(" ", "")
        uri = Addressable::URI.parse("https://maps.googleapis.com/maps/api/directions/json?origin=#{ekimei}&destination=#{address}&key=#{API_KEY}")
        json = Net::HTTP.get(uri)

        if kyroi < JSON.parse(json)["routes"][0]["legs"][0]["distance"]["value"]
            pr["distance"] = JSON.parse(json)["routes"][0]["legs"][0]["distance"]
            @finish << pr
        end
      end
    end

    @finish

  end
end
