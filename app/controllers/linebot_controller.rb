require 'date'
require './app/controllers/concerns/methods.rb'

class LinebotController < ApplicationController
    protect_from_forgery except: :sort
    
    def callback
        body = request.body.read
        events = client.parse_events_from(body)
        
        events.each do |event|
            case event
            when Line::Bot::Event::Message
                case event.type
                when Line::Bot::Event::MessageType::Text
                    inputText = event.message['text']

                    if inputText.eql?("出勤時間登録")
                        regist_begin_time_confirm(event)

                    elsif inputText.eql?("退勤時間登録")
                        regist_finish_time_confirm(event)

                    elsif inputText.eql?("今日の勤務記録")
                        show_today_record(event)

                    elsif inputText.eql?("今月の勤務記録")
                        show_this_month_record(event)

                    elsif inputText.eql?("先月の勤務記録")
                        show_last_month_record(event)

                    elsif inputText.eql?("今日の勤務記録を修正")
                        fix_today_record_confirm(event)
                    end
                end
            when Line::Bot::Event::Postback
                data = event['postback']['data'].split('&').map{|w| w.split('=')}.to_h
                action = data['action']
                res = data['res']
                
                if action.eql?('begin')
                    regist_begin_time_action(event,res)
                elsif action.eql?('finish')
                    regist_finish_time_action(event,res)
                elsif action.eql?('fix')
                    fix_today_record_action(event,res)
                end               
            end            
        end 
        head :ok
    end
end