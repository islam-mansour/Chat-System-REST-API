class MessageDto

    def initialize(message)
        @number = message['number']
        @body = message['body']
        @created_at = message['created_at']
    end

end
