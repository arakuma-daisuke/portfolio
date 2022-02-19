class LineBotController < ApplicationController
require 'line/bot'

  protect_from_forgery except: [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      # config.channel_id = ENV["1656854473"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']                                     # リクエストがLINEプラットフォームから送られたことを確認する
    unless client.validate_signature(body, signature)                                    # Webhookイベントのシグネチャを検証します。
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)                                              # request.bodyからイベントを解析する
    events.each do |event|
      case event
      when Line::Bot::Event::Message 
        message = case event.type
        when Line::Bot::Event::MessageType::Text                                         # 送られてきたメッセージがテキストだった場合
          #message1 = review_focus(event.message['text'])
          message = distance_focus(event.message['text'])
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video  # テキスト以外が送られてきた場合
          message = { type: 'text', text: 'このアプリの使い方を記入する'}
          client.reply_message(event['replyToken'], message)
        end
      end

      message = {
        type: 'text',
        text: 'hello'
      }
      client = Line::Bot::Client.new { |config|
          config.channel_secret = "<channel secret>"
          config.channel_token = "<channel access token>"
      }
      response = client.push_message("<to>", message)
      p response
    end
    head :ok
  end

  private

  def review_focus(keyword)
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY']) # APIキーの確認
    list = client.spots_by_query(keyword, language: 'ja', rating: 4, types: 'restaurant', detail: true) # キーワードで検索できる星３以上で日本語表記されてる店を探す  rating: '3以上 , detail: true 
    response = list.sample
    message = {
      type: 'text',
      text: response[:url]
    }
  end 

  def distance_focus(keyword)
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY']) # APIキーの確認
    list = client.spots_by_query(keyword, language: 'ja', radius: 1000, types: 'restaurant', detail: true) # キーワードで検索できる半径１キロ以内で日本語表記されてる店を探す
    response = list.sample
    message = {
      type: 'text',
      text: response[:url]
    }
  end
end
