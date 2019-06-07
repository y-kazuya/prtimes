class PagesController < ApplicationController
  API_KEY = "AIzaSyAu--Z2zo37olt65ga_kQ2rJLBzNT_u6Ys"
  PAGE_RESULTS = []
  MAX_ONCE = 5
  $store_pres = []
  $page_number = 0
  def index

  end

  def summary
    #期間は3ヶ月
    @end = true
    @page = 0 unless @page
    @page = params[:page]
    @pg = $page_number
    @page_results = PAGE_RESULTS

    @finish = []
    @d1 = "1"

    PAGE_RESULTS.each do |page_result|
      if page_result[0] == @page
        @finish =  page_result[1]
      end
    end
    @d1 = "1.5"
    return @finish if @finish.length != 0


    # if $store_pres != []
    #   @finish = $store_pres
    #   $store_prs = Array.new
    # end

    # @d1 = "2"

    # return @finish if @finish.length != 0

    ekimei = "新宿"
    category = 2
    kyroi = 3
    ago = 3

    #今日から3ヶ月前までのPRを取得
    today = Date.today
    from = Time.current.ago(ago.month).to_s.split(" ")[0]

    @result = []


    @d1 ="3"
    until @finish.length >= MAX_ONCE
      $page_number += 1
        uri = URI.parse("https://9b199e13.prtimes.tech/date_period/#{from}/#{today}/#{$page_number}")
        json = Net::HTTP.get(uri) #NET::HTTPを利用してAPIを叩く
        break if JSON.parse(json)["data"] == []

        JSON.parse(json)["data"].each do |pr|

          url = URI.parse("https://9b199e13.prtimes.tech/detail/#{pr['company_id'].to_i}/#{pr['release_id'].to_i}/")
          json = Net::HTTP.get(url)
          if (JSON.parse(json)["data"]["address"] != [] || JSON.parse(json)["data"]["address"][0] != nil)
            @result << JSON.parse(json)["data"]
          end
      end #@result 期間（三ヶ月以内と、住所があるかどうか、カテゴリー一致してるかどうかで絞ってる



      break if @result == []
      @result.each do |pr|
        if pr["address"][0] != nil

          address = pr["address"][0].gsub(" ", "")
          uri = Addressable::URI.parse("https://maps.googleapis.com/maps/api/directions/json?origin=#{ekimei}&destination=#{address}&key=#{API_KEY}")
          json = Net::HTTP.get(uri)

          if kyroi < JSON.parse(json)["routes"][0]["legs"][0]["distance"]["value"]
              pr["distance"] = JSON.parse(json)["routes"][0]["legs"][0]["distance"]
              if  @finish.length >= MAX_ONCE
                 $store_pres << pr
              else
                 @finish << pr
              end
          end
        end
      end
    end

    @finish.length >= MAX_ONCE ? @end = true : @end = false
    @d1 ="4"
    PAGE_RESULTS << [@page,@finish]
    @page_results = PAGE_RESULTS
    @page = @page.to_i
    @finish

  end
end
