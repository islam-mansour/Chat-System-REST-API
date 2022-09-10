require "#{Rails.root}/app/factory/rabbitMQ_builder.rb"
require "#{Rails.root}/app/models/dtos/message.rb"

module Api
    module V1
        class ChatsController < ApplicationController
            skip_before_action :verify_authenticity_token


            def_param_group :chat do
                param :id, :number, desc: 'Chat id'	  
                property :number, :number, desc: 'Chat number for the application (Starting from 1)'  
                property :application_id, :number, desc: 'Application id that this chat belongs to'  
                param :messages_count, :number, desc: 'Number of messages belongs to the chat'
                property :created_at, String, desc: 'Date of the chat creation'  
                property :updated_at, String, desc: 'Last time the chat was updated'
            end

            

            
            api :GET, '/chats/', 'Shows all applications'  
            returns array_of: :chat, code: 200, desc: 'All chats'
            def index
                chats = Chat.order('created_at DESC')
                chatsDtos = Array.new
                chats.each do |chat|
                    chatsDtos.push(ChatDto.new(chat))
                end
                render json: {status: "SUCCESS", data: chatsDtos}, status: 200
            end

            
            
            api :GET, '/applications/<token>/chats/<number>/messages', 'Shows all messages belongs to this chat'  
            returns array_of: :chat, code: 200, desc: 'All applications'
            def messages
                application = Application.where(token: params[:token])
                if !application.exists?
                    render json: {status: "APPLICATION_NOT_FOUND"}, status: 404
                    return
                end

                chat = Chat.where(application_id: application.first['id'], number: params[:number])
                if !chat.exists?
                    render json: {status: "NOT_FOUND"}, status: 404
                    return
                end

                messages = Message.where(chat_id: chat.first['id'])
                messages_dto = Array.new
                messages.each do |chat|
                    messages_dto.push(MessageDto.new(chat))
                end
                
                render json: {data: messages_dto}, status: 200
            end

            
            api :GET, '/chats/<application_token>-<chat_number>', 'Show chat'  
            returns array_of: :chat, code: 200, desc: 'Chat'
            def show
                application_token, chat_number = params[:id].split('-')[0],params[:id].split('-')[1]
                application = Application.where(token: application_token)
                if application.exists?
                    chat = Chat.where(application_id: application.first['id'], number: chat_number)
                    if chat.exists?
                        render json: {status: "SUCCESS", data: ChatDtos.new(chat.first)}, status: 200
                        return
                    end
                end
                render json: {status: "NOT_FOUND"}, status: 404
            end
            
            
            api :POST, '/chats/', 'Create chat'
            returns array_of: :chat, code: 200, desc: 'Created chat'
            def create
                application_token = params[:application]
                number = 1
                if $redis.get("last_number_application_token_" + application_token) != nil
                    number = $redis.get("last_number_application_token_" + application_token).to_i + 1
                end

                r = RabbitMQ_builder.new
                queue = r.buildQueue('chats')
                record = params[:application] + "," + number.to_s
                r.publish(queue, record)
                
                render json: {status: "SUCCESS", chat_number: number}, status: 200
            end

            
            api :DELETE, '/chats/<token>', 'Delete chat'  
            returns array_of: :chat, code: 200, desc: 'Delete chat'
            def destroy
                chat = Chat.where(id: params[:id])
                if chat.exists?
                    chat.first.destroy
                    render json: {status: "SUCCESS"}, status: 200
                else
                    render json: {status: "NOT_FOUND"}, status: 404
                end
            end

            def update
                #TODO: Ask if chats is allowed to be updated
            end

        end
    end
end