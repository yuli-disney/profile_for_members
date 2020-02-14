module Body
  class Action
      def initialize(json)
          @json=json
      end
      def interact
          conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
              builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
              builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
              builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
          end
          natsuo = Faraday::Connection.new(:url => 'https://mates-profile-app.herokuapp.com') do |builder|
            builder.use Faraday::Request::UrlEncoded  
            builder.use Faraday::Response::Logger     
            builder.use Faraday::Adapter::NetHttp    
          end
          p "これがアクションのjson"
          p @json
          p "ここまで"
          
           if @json["type"]=="block_actions"
            response = conn.get do |req|  
                req.url '/api/users.list'
                req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
              end
               info = JSON.parse(response&.body)
               members=info["members"]
               p "この間がメンバー"
         #      p members
               p "この間メンバー"
               for var in members do
                p "テキストとその下は名前！"
                p @json["message"]["text"]
                p var["profile"]["real_name"]
                if @json["message"]["text"].include?(var["profile"]["real_name"])
                  p "下がアクションの名前"
                  p var["id"]
                  break
                end
               end
            p @json["user"]
            p "ユーザー確認"
            response = natsuo.get do |req|  
                req.url '/login'               
                req.headers[:is_index] = "false"
                req.headers[:member_slack_id] = var["id"]
                req.headers[:workspace_id] = @json["team"]["id"]
                req.headers[:slack_user_id] = @json["user"]["id"]
                p var["id"]
                p req.body
              end
            view = {
              "type": "modal",
              "title": {
                  "type": "plain_text",
                  "text": "質問箱"
              },
              "blocks": [
                  {
                  "type": "section",
                  "text": {
                      "type": "mrkdwn",
                      "text": "あなたが好きな映画は？"
                  },
                  "block_id": "section1",
                   },
                  {
                  "type": "input",
                  "label": {
                      "type": "plain_text",
                      "text": "Input label"
                  },
                  "element": {
                      "type": "plain_text_input",
                      "action_id": "input1",
                      "placeholder": {
                      "type": "plain_text",
                      "text": "Type in here"
                      },
                      "multiline": false
                  },
                  "optional": false
                  }
              ],
              "close": {
                  "type": "plain_text",
                  "text": "Cancel"
              },
              "submit": {
                  "type": "plain_text",
                  "text": "Save"
              },
              "private_metadata": "Shhhhhhhh",
              "callback_id": "view_identifier_12"
              }

              body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],#あとでherokuで設定します
              :trigger_id => @json["trigger_id"],#こうするとDM内に返信できます
              :view => view
              }
            conn.post '/api/views.open',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}#ヘッダーはつけなければいけないらしい、このままで大丈夫です。
           
           else
            response = conn.get do |req|  
              req.url '/api/users.list'
              req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
            end
             info = JSON.parse(response&.body)
             members=info["members"]
             p "この間がメンバー"
       #      p members
             p "この間メンバー"
             for var in members do
              p "テキストとその下は名前！"
              p @json["message"]["text"]
              p var["profile"]["real_name"]
              if @json["message"]["text"].include?(var["profile"]["real_name"])
                p "下がアクションの名前"
                p var["id"]
                break
              end
             end
  

            @json["user"]
            response = natsuo.get do |req|  
                req.url '/login'               
                req.headers[:is_index] = "false"
                req.headers[:member_slack_id] = var["id"]
                req.headers[:workspace_id] = @json["team"]["id"]
                req.headers[:slack_user_id] = @json["user"]["id"]
                p var["id"]
                p req.body
              end
            
            end
      end
  end   
end