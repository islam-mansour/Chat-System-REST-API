class ChatDto

    def initialize(chat)
        @number = chat['number']
        @messages_count = chat['messages_count']
        @created_at = chat['created_at']
    end

end
