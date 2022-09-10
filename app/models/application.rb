class Application < ApplicationRecord
    has_many :chats

    def self.hello
        applications = Application.all
        applications.each do |application|
            application.chats_count = application.chats_count + 1
            application.save
        end
    end

end
