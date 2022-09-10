require 'bunny'

class RabbitMQ_builder
    def initialize
        @connection = Bunny.new(hostname: 'rabbitmq')
        @connection.start
        @channel = @connection.create_channel
    end
    
    def buildQueue(name)
        queue = @channel.queue(name)
        return queue
    end

    def publish(queue, message)
        @channel.default_exchange.publish(message, routing_key: queue.name)
    end

end