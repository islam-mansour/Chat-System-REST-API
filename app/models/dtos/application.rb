class ApplicationDto

    def initialize(application)
        @token = application['token']
        @name = application['name']
        @chats_count = application['chats_count']
        @created_at = application['created_at']
    end

end
