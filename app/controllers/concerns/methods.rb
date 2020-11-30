def regist_begin_time_confirm(event)
    message = {
        "type": "template",
        "altText": "this is a confirm template",
        "template": {
            "type": "confirm",
            "text": "出勤時間を登録しますか?",
            "actions": [
                {
                    "type": "postback",
                    "label": "はい",
                    "data": "action=begin&res=yes"
                },
                {
                    "type": "postback",
                    "label": "いいえ",
                    "text": "no",
                    "data": "action=begin&res=no"
                }
            ]
        }
    }
    client.reply_message(event['replyToken'], message)
end

def regist_finish_time_confirm(event)
    message = {
        "type": "template",
        "altText": "this is a confirm template",
        "template": {
            "type": "confirm",
            "text": "退勤時間を登録しますか?",
            "actions": [
                {
                    "type": "postback",
                    "label": "はい",
                    "data": "action=finish&res=yes"
                },
                {
                    "type": "postback",
                    "label": "いいえ",
                    "text": "no",
                    "data": "action=finish&res=no"
                }
            ]
        }
    }
    client.reply_message(event['replyToken'], message)
end

def show_today_record(event)
    user_id = event['source']['userId']
    today = Date.today
    record =  Attendance.where(user_id: "#{user_id}", work_date: "#{today}").take
    text = "今日の勤務記録\n"

    if record.nil?
        text << "----------------\n"
        text << "記録なし\n"
        text << "----------------"
    else
        begin_time = record.begin_time.strftime("%H:%M")
        finish_time = record.finish_time
        if finish_time.nil?
            finish_time = '記録なし'
            text << "#{record.work_date}\n出勤時間：#{begin_time}\n退勤時間：#{finish_time}"
        else
            finish_time = record.finish_time.strftime("%H:%M")
            total_time = Time.at(record.finish_time - record.begin_time).utc.strftime('%-H:%M')
            text << "#{record.work_date}\n出勤時間：#{begin_time}\n退勤時間：#{finish_time}\n勤務時間：#{total_time}\n"
        end
    end
    message = {
        type: 'text',
        text: text
    }
    client.reply_message(event['replyToken'], message)
end

def show_this_month_record(event)
    user_id = event['source']['userId']
    this_month = Date.today.strftime("%Y-%m")
    records =  Attendance.where(user_id: "#{user_id}").where('work_date like ?',"#{this_month}%")
    text = "今月の勤務記録\n"
    
    if records[0].nil?
        text << "----------------\n"
        text << "記録なし\n"
        text << "----------------"
    else
        records.each do |record|
            begin_time = record.begin_time.strftime("%H:%M")
            finish_time = record.finish_time
            
            if finish_time.nil?
                finish_time = '記録なし'
            else
                finish_time = record.finish_time.strftime("%H:%M")
                worked_time = Time.at(record.finish_time - record.begin_time).utc.strftime('%-H:%M')
            end
            text << "----------------\n"
            text << "#{record.work_date}\n出勤時間：#{begin_time}\n退勤時間：#{finish_time}\n勤務時間：#{worked_time}\n"
        end
    end
    message = {
        type: 'text',
        text: text
    }
    client.reply_message(event['replyToken'], message)
end

def show_last_month_record(event)
    user_id = event['source']['userId']
    last_month = (Time.now - 1.month).strftime("%Y-%m")
    records =  Attendance.where(user_id: "#{user_id}").where('work_date like ?',"#{last_month}%")
    text = "先月の勤務記録\n"

    if records[0].nil?
        text << "----------------\n"
        text << "記録なし\n"
        text << "----------------"
    else
        records.each do |record|
            begin_time = record.begin_time.strftime("%H:%M")
            finish_time = record.finish_time
            
            if finish_time.nil?
                finish_time = '記録なし'
            else
                finish_time = record.finish_time.strftime("%H:%M")
                total_time = Time.at(record.finish_time - record.begin_time).utc.strftime('%-H:%M')
            end
            text << "----------------\n"
            text << "#{record.work_date}\n出勤時間：#{begin_time}\n退勤時間：#{finish_time}\n勤務時間：#{total_time}\n"
        end
    end
    message = {
        type: 'text',
        text: text
    }
    client.reply_message(event['replyToken'], message)    
end

def fix_today_record_confirm(event)
    user_id = event['source']['userId']
    today = Date.today
    record =  Attendance.where(user_id: "#{user_id}", work_date: "#{today}").take
    
    if record.nil?
        message = {
            type: 'text',
            text: "今日の出勤時間が登録されていません。\nまずは出勤時間を登録してください。"
        }
        client.reply_message(event['replyToken'], message)
    else
        begin_time = record.begin_time.strftime("%H:%M")
        finish_time = record.finish_time

        if finish_time.nil? 
            finish_time = '記録なし'
        else 
            finish_time = finish_time.strftime("%H:%M")
        end
        
        message = {
            "type": "template",
            "altText": "今日の勤務登録修正確認",
            "template": {
                "type": "buttons",
                "text": "#{today}\n出勤時間：#{begin_time}\n退勤時間：#{finish_time}\nどちらを修正しますか？",
                "actions": [
                    {
                        "type": "datetimepicker",
                        "label": "出勤時間",
                        "mode": "time",
                        "data": "action=fix&res=begin_fix"
                    },
                    {
                        "type": "datetimepicker",
                        "label": "退勤時間",
                        "mode": "time",
                        "data": "action=fix&res=finish_fix"
                    },
                    {
                        "type": "postback",
                        "label": "修正しない",
                        "data": "action=fix&res=cancel"
                    }
                ]
            }
        }
        client.reply_message(event['replyToken'], message)  
    end
end

def regist_begin_time_action(event,res)
    if res.eql?('yes')
        user_id = event['source']['userId']
        today = Date.today
        now = Time.now
        nowTime = now.strftime("%H:%M")
        record = Attendance.where(user_id: "#{user_id}", work_date: "#{today}").take
        if record.nil?
            Attendance.create!(user_id: user_id, work_date: today, begin_time: nowTime)
            message = {
                type: 'text',
                text: "(#{nowTime})出勤時間を登録しました"
            }
        else
            message = {
                type: 'text',
                text: "今日の出勤時間は既に登録してあります。"
            }
        end 
        client.reply_message(event['replyToken'], message)
    else
        message = {
            type: 'text',
            text: "登録をキャンセルしました"
        }
        client.reply_message(event['replyToken'], message)
    end
end

def regist_finish_time_action(event,res)
    if res.eql?('yes')
        user_id = event['source']['userId']
        today = Date.today
        now = DateTime.now
        nowTime = now.strftime("%H:%M")
        record = Attendance.where(user_id: "#{user_id}", work_date: "#{today}").take 
        
        if record.nil?
            message = {
                type: 'text',
                text: "今日の出勤時間が登録されていません。\n先に出勤時間を登録してください。"
            }
            client.reply_message(event['replyToken'], message)
        elsif record.finish_time.nil?
            record = Attendance.where(user_id: "#{user_id}", work_date: "#{today}")
            record.update(finish_time: nowTime)
            message = {
                type: 'text',
                text: "(#{nowTime})退勤時間を登録しました"
            }
            client.reply_message(event['replyToken'], message)
        else
            message = {
                type: 'text',
                text: "今日の退勤時間は既に登録されています。"
            }
            client.reply_message(event['replyToken'], message)
        end
    else 
        message = {
            type: 'text',
            text: "登録をキャンセルしました"
        }
        client.reply_message(event['replyToken'], message)
    end
end

def fix_today_record_action(event,res)
    if res.eql?('begin_fix')
        user_id = event['source']['userId']
        today = Date.today
        fix_record = Attendance.where(user_id: "#{user_id}", work_date: "#{today}").take
        before_fix_begin_time = fix_record.begin_time.strftime("%H:%M")
        after_fix_begin_time = event['postback']['params']['time']
        
        fix_record.update(begin_time: "#{after_fix_begin_time}")

        message = {
            'type': 'text',
            'text': "#{today}\n出勤時間の修正を完了しました。\n#{before_fix_begin_time}⇒#{after_fix_begin_time}"
        }
        client.reply_message(event['replyToken'], message)
    elsif res.eql?('finish_fix')
        user_id = event['source']['userId']
        today = Date.today
        fixed_finish_time = event['postback']['params']['time']
        fix_record = Attendance.where(user_id: "#{user_id}", work_date: "#{today}").take
        before_fix_finish_time = fix_record.finish_time.strftime("%H:%M")
        after_fix_finish_time = event['postback']['params']['time']

        fix_record.update(finish_time: "#{after_fix_finish_time}")

        message = {
            'type': 'text',
            'text': "#{today}\n退勤時間の修正を完了しました。\n#{before_fix_finish_time}⇒#{after_fix_finish_time}"
        }
        client.reply_message(event['replyToken'], message)
    else 
        message = {
            'type': 'text',
            'text': '修正をキャンセルしました。'
        }
        client.reply_message(event['replyToken'], message)
    end
end

