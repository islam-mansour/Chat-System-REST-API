#!/usr/bin/env ruby
require 'bunny'
require '../../config/environment.rb'

begin
    puts ' [*] Waiting for messages. To exit press CTRL+C'
    # block: true is only used to keep the main thread
    # alive. Please avoid using it in real world applications.
    connection = Bunny.new(hostname: 'rabbitmq')
    connection.start
    
    channel = connection.create_channel
    queue = channel.queue('messages')

    queue.subscribe(block: true) do |_delivery_info, _properties, body|
        puts " [x] Received #{body}"
        application_token, chat_number, body, number = body.split(',')[0], body.split(',')[1], body.split(',')[2], body.split(',')[3]

        application = Application.where(:token => application_token)
        if !application.exists?
            puts "Application not found"
            return
        end
    
        chat = Chat.where(:application_id => application.first['id'], :number => chat_number)
        if !chat.exists?
            puts "Chat not found"
            return
        end

        key = "last_number_application_token_" + application_token + "_chat_number_" + chat_number.to_s
        $redis.set(key, number)

        message = Message.new(chat_id: chat.first['id'], number: number, body: body)
        if message.save
            puts "Message created"
        else
            puts "Message Error"
        end
    end
rescue Interrupt => _
    connection.close()
    exit(0)
end
