class PagesController < ApplicationController
  API_KEY = "AIzaSyAu--Z2zo37olt65ga_kQ2rJLBzNT_u6Ys"
  @@page_result = []

  MAX_ONCE = 5
  @@store_pres = []
  @@page_number = 0
  def index

  end

  def summary



    if params['eki']
      @@store_pres = []
      @@page_result = []
      @@page_number = 0
      @ekimei = params['eki'] + "駅"
    else
      @ekimei = params['ekimei']
    end
    #期間は3ヶ月
    @end = true
    @page = 1 unless @page
    @page = params[:page]
    @cate = params[:cate]
    @pg = @@page_number
    @page_results =  @@page_result

    @finish = []
    @d1 = "1"

    if params['eki']
      @ekimei = params['eki'] + "駅"
    else
      @ekimei = params['ekimei']
    end

    if params["dis"]
      @kyori = params["dis"].to_i * 1000
    else
      @kyori= params['kyori'].to_i
    end

    ago = 3


    @@page_result.each do |page_result|
      if page_result[0] == @page
        @finish =  page_result[1]
      end
    end
    @d1 = "1.5"
    return @finish if @finish.length != 0


    if @@store_pres != []
      @finish = @@store_pres
      @@store_pres = []
    end

    if @finish.length >=  MAX_ONCE
      @@page_result << [@page,@finish]
    end

    return @finish if @finish.length >=  MAX_ONCE



    #今日から3ヶ月前までのPRを取得
    today = Date.today
    from = Time.current.ago(ago.month).to_s.split(" ")[0]

    @result = []
    start_time = Time.now
    until @finish.length >= MAX_ONCE
      break if Time.now - start_time > 20

      @@page_number += 1
      uri = URI.parse("https://9b199e13.prtimes.tech/date_period/#{from}/#{today}/#{@@page_number}")
      json = Net::HTTP.get(uri) #NET::HTTPを利用してAPIを叩く
      break if JSON.parse(json)["data"] == []


      JSON.parse(json)["data"].each do |pr|

        url = URI.parse("https://9b199e13.prtimes.tech/detail/#{pr['company_id'].to_i}/#{pr['release_id'].to_i}/")
        json = Net::HTTP.get(url)

        if (JSON.parse(json)["data"]["address"] != [] || JSON.parse(json)["data"]["address"][0] != nil)
          prpr= JSON.parse(json)["data"]
          prpr["company_id"] = JSON.parse(json)["company_id"]
          prpr["release_id"] = JSON.parse(json)["release_id"]
          if @cate
            @result << prpr if prpr["main_category_id"].to_i == @cate.to_i || !@result.include?(prpr)
          else
            @b = 1
            @result << prpr if !@result.include?(prpr)
          end

        end

      end #@result 期間（三ヶ月以内と、住所があるかどうか、カテゴリー一致してるかどうかで絞ってる"main_category_id"



      break if @result == []
      @result.each do |pr|
        if pr["address"][0] != nil

          address = pr["address"][0].gsub(" ", "")
          uri = Addressable::URI.parse("https://maps.googleapis.com/maps/api/directions/json?origin=#{@ekimei}&destination=#{address}&key=#{API_KEY}")
          json = Net::HTTP.get(uri)

          return unless JSON.parse(json)["routes"][0] && JSON.parse(json)["routes"][0]["legs"][0]

          if @kyori > JSON.parse(json)["routes"][0]["legs"][0]["distance"]["value"]
              pr["distance"] = JSON.parse(json)["routes"][0]["legs"][0]["distance"]
              if  @finish.length >= MAX_ONCE
                 @@store_pres << pr
              else

                 @finish << pr unless @finish.include?(pr)
              end
          end
        end
      end
    end

    render action: :noshow if @finish.length == 0
    @@page_result << [@page,@finish]
    @page_results = @@page_result
    @page = @page.to_i
    @params = params["category"]
    @time = Time.now - start_time
    @finish

  end

  def noshow

  end
end
