#!/usr/bin/env ruby
require 'bunny'
require '../../config/environment.rb'

begin
    connection = Bunny.new(hostname: 'rabbitmq')
    connection.start

    channel = connection.create_channel
    queue = channel.queue('chats')

    puts ' [*] Waiting for messages. To exit press CTRL+C'
    # block: true is only used to keep the main thread
    # alive. Please avoid using it in real world applications.
    queue.subscribe(block: true) do |_delivery_info, _properties, body|
        puts " [x] Received #{body}"
    
        application_token, number = body.split(",")[0], body.split(",")[1].to_i
        application = Application.where(:token => application_token)
        if !application.exists?
            puts "No such Application"
            return
        end        

        $redis.set("last_number_application_token_" + application_token, number)

        chat = Chat.new(application_id: application.first['id'], number: number)

        if chat.save
            puts "Success"
        else
            puts "Error"
        end
    end
rescue Interrupt => _
    connection.close()
    exit(0)
end