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
          p "次はjsonのアクション"
          p "ここまで"
          
           if @json["type"]=="block_actions"
            p "この子はブロックなのです"
            value=@json["actions"][0]["value"]
            p @json["actions"][0]["value"]
                if @json["actions"][0]["value"]=="link"
                    response = conn.get do |req|  
                        req.url '/api/users.list'
                        req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
                    end
                    info = JSON.parse(response&.body)
                    members=info["members"]
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
                    
                else
                    p value
                    valuearray = value.split('+')
                    p valuearray[0]
                    viewquestion= valuearray[0]
                    id=valuearray[1]
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
                                "text": "#{viewquestion}"
                            },
                            "block_id": "#{id}"
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
                    end
            elsif @json["type"]=="view_submission"
                p "valueありますか？"
                p @json
                id=@json["view"]["blocks"][0]["block_id"]
                block_id=@json["view"]["blocks"][1]["block_id"]
                p @json["view"]["state"]["values"]
                p @json["view"]["state"]["values"][block_id]["input1"]["value"]
                question  = @json["view"]["blocks"][0]["text"]["text"]
                answer=@json["view"]["state"]["values"][block_id]["input1"]["value"]
                p "valueありますか？"
                # body = {
                #     :token => ENV['SLACK_BOT_USER_TOKEN'],#あとでherokuで設定します
                #     :channel => "general",#こうするとDM内に返信できます
                #     :text  => "あなたの回答は#{@json["view"]["state"]["values"][block_id]["input1"]["value"]}です。回答が送信されました！"
                #     }
                # conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}#ヘッダーはつけなければいけないらしい、このままで大丈夫です。

                body ={
                    :content => question,
                    :answer => answer
                }
                natsuo.put "/api/v1/questions/#{id}",body.to_json, {"Content-type" => 'application/json',"workspace-id"=>@json["view"]["team_id"],"slack-user-id"=>@json["user"]["id"]}
    
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
              #p @json["message"]["text"]
              p var["profile"]["real_name"]
            #   if @json["message"]["text"].include?(var["profile"]["real_name"])
            #     p "下がアクションの名前"
            #     p var["id"]
            #     break
            #   end
             end
  

            #@json["user"]
            
            
            end
      end
  end   
end