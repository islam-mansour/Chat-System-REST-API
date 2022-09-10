require "#{Rails.root}/app/factory/rabbitMQ_builder.rb"
require "#{Rails.root}/app/models/dtos/message.rb"
require 'elasticsearch/model'

module Api
    module V1
        class MessagesController < ApplicationController
            skip_before_action :verify_authenticity_token

            def_param_group :message do
                param :id, :number, desc: 'Message id'	  
                property :number, :number, desc: 'Message number for the chat (Starting from 1)'  
                property :chat_id, :number, desc: 'Chat id that this message belongs to'  
                property :created_at, String, desc: 'Date of the message creation'  
                property :updated_at, String, desc: 'Last time the message was updated'
            end


            api :GET, '/messages/', 'Shows all messages'  
            returns array_of: :message, code: 200, desc: 'All messages'
            def index
                messages = Message.order('created_at DESC')
                messagesDtos = Array.new
                messages.each do |message|
                    messagesDtos.push(MessageDto.new(message))
                end
                render json: {status: "SUCCESS", data: messagesDtos}, status: 200
            end

            
            api :POST, '/messages/search', 'Search for message by content'  
            returns array_of: :message, code: 200, desc: 'Messages'
            def search
                search_results = Message.search(params[:message])
                matched_messages = Array.new
                search_results.each do |result|
                    matched_messages.push(MessageDto.new(result['_source']))
                end
                render json: {'data': matched_messages}, status: 200
            end

            
            api :GET, '/messages/<application_token>-<chat_number>-<message_number>', 'Shows message'  
            returns array_of: :message, code: 200, desc: 'Message'
            def show
                application_token, chat_number, message_number = params[:id].split('-')[0], params[:id].split('-')[1], params[:id].split('-')[2]
                application = Application.where(:token => application_token)
                if !application.exists?
                    render json: {status: "NOT_FOUND_APPLICATION"}, status: 404
                    return
                end

                chat = Chat.where(:application_id => application.first['id'], number: chat_number)
                if !chat.exists?
                    render json: {status: "NOT_FOUND_CHAT"}, status: 404
                    return
                end

                message = Message.where(:chat_id => chat.first['id'], number: message_number)
                if !message.exists?
                    render json: {status: "NOT_FOUND_MESSAGE"}, status: 404
                    return
                end

                render json: {status: "SUCCESS", data: MessageDto.new(message.first)}, status: 201

            end
            
            
            api :POST, '/message/', 'Create message'  
            returns array_of: :message, code: 200, desc: 'Create message'
            def create
                number = 1
                application_token = params[:application]
                chat_number = params[:chat]
                key = "last_number_application_token_" + application_token + "_chat_number_" + chat_number.to_s
                if $redis.get(key) != nil
                    number = $redis.get(key).to_i + 1
                end
                         
                r = RabbitMQ_builder.new
                queue = r.buildQueue('messages')
                record = application_token + ',' + chat_number.to_s + ',' + params[:message] + ',' + number.to_s
                r.publish(queue, record)
                render json: {status: "SUCCESS", message_number: number}, status: 200
            end

            
            api :GET, '/message/<id>', 'Delete message'  
            returns array_of: :message, code: 200, desc: 'Deleted message'
            def destroy
                message = Message.where(:id => params[:id])
                if message.exists?
                    message.first.destroy
                    render json: {status: "SUCCESS"}, status: 200
                else
                    render json: {status: "NOT_FOUND"}, status: 404
                end
            end

            def update
                #TODO: Ask if messages is allowed to be updated
            end
            
        end
    end
end