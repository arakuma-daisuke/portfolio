class LineBotController < ApplicationController
require 'line/bot'

protect_from_forgery except: [:callback]

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["1656854473"]
    config.channel_secret = ENV["23a87fd15e9e4d52bf93b91c74f7c4f0"]
    config.channel_token = ENV["HtGdUYMd5d889xJxkFjXiQDcq / 82 / oQTKsBqDlj5y1cCZZDW0uYPq5YpBwzX37fFhOk3IMPXpf + 0fpK2yxxSXy4En4haV6jko6Lt6gRgR60Ho / XB9r"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE'] # リクエストがLINEプラットフォームから送られたことを確認する
  unless client.validate_signature(body, signature) # Webhookイベントのシグネチャを検証します。
    error 400 do 'Bad Request' end
  end

  #  確認用テンプレートを作成
  Line::Bot::Event::MessageType::Buttons # 間違ってるかも
  {
    "type": "template",
    "altText": "選択肢",
    "template": {
        "type": "confirm",
        "text": "どちらを重視しますか？",
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

# キーワードと地域を入力する
    





  events = client.parse_events_from(body) # request.bodyからイベントを解析する
  events.each do |event|
    case event
    when Line::Bot::Event::Message 
      message = case event.type
      when Line::Bot::Event::MessageType::Text # 送られてきたメッセージがテキストだった場合
        { type: 'text', text: 2}

      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video # テキスト以外が送られてきた場合
        { type: 'text', text: 'テキストで記入してください'}
        client.reply_message(event['replyToken'], message)
    end
  end
  # Don't forget to return a successful response
  "OK"
end

  private

  def ２択の判定
    case event.message['text']
    when 'レビュー'
        @choices = 'レビュー'
    when '距離'
        @choices = '距離'
    end

  end

  def キーワード読み取り

  end

end
