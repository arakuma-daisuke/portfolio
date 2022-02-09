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

    signature = request.env['HTTP_X_LINE_SIGNATURE'] # リクエストがLINEプラットフォームから送られたことを確認する
    unless client.validate_signature(body, signature) # Webhookイベントのシグネチャを検証します。
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body) # request.bodyからイベントを解析する
    events.each do |event|
      case event
      when Line::Bot::Event::Message 
        message = case event.type
        when Line::Bot::Event::MessageType::Text # 送られてきたメッセージがテキストだった場合
          message = google_places(event.message['text'])
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video # テキスト以外が送られてきた場合
          message = { type: 'text', text: 'このアプリの使い方を記入する'}
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    # Don't forget to return a successful response
    head :ok
  end

  private

  def search_and_create_message(keyword)
    http_client = HTTPClient.new
    url = 'https://app.rakuten.co.jp/services/api/Travel/KeywordHotelSearch/20170426'
    query = {
      'keyword' => keyword,
      'applicationId' => ENV['RAKUTEN_APPID'],
      'hits' => 5,
      'responseType' => 'small',
      'datumType' => 1,
      'formatVersion' => 2
    }
    response = http_client.get(url, query)
    response = JSON.parse(response.body)

    if response.key?('error')
      text = "この検索条件に該当する宿泊施設が見つかりませんでした。\n条件を変えて再検索してください。"
      {
        type: 'text',
        text: text
      }
    else
      検索できた場合の処理
    end
  end

  def google_places(keyword)
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY']) # APIキーの確認
    list = client.spots_by_query(keyword, language: 'ja') # キーワードで検索できる星３以上で日本語表記されてる店を探す  rating: '3以上 , detail: true 
    response = list.sample
    text = ''
      text <<
      response[@name]
    p text
  end


  #  選択肢テンプレート作成 rakeで回す予定
  def choice # 送信用 確認テンプレートと悩み中
    message = {
      "type": "template",
      "altText": "代価テキスト",
      "template": {
          "type": "buttons",
          "title": "レビューと距離どちらを重視しますか？",
          "text": "選択してください",
          "defaultAction": {
              "type": "message",
              "label": "defaultAction",
              "text": "defaultActionです"
          },
          "actions": [
              {
                  "type": "message",
                  "label": "レビュー",
                  "text": "レビュー"
              },
              {
                  "type": "message",
                  "label": "距離",
                  "text": "距離"
              }
          ]
      }
    }
    response = client.push_message("<to>", message) # ユーザーにメッセージを送る
    p response
  end

  def Keyword_input
    message = {
      type: 'text',
      text: 'お店を探したい地域を入力してください'
    }

    response = client.push_message("<to>", message)
    p response
  end

  def recommend
    # 受け取った値をグーグルマップで処理してここでURLを表示 リッチなんとかを使うかも
  end

  def select
    case event.message['text']
    when 'レビュー'
        @choices = 'レビュー'
    when '距離'
        @choices = '距離'
    end
  end

  def keyword
    @keyword = event.message['text']
  end
end
