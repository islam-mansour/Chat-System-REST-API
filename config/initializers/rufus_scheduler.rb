require 'rufus-scheduler'

Rufus::Scheduler.singleton.every '1h' do
    applications = Application.all
    applications.each do |application|

        count = 0
        if $redis.get("chats_count_application_id_" + application['id'].to_s) != nil
            count = $redis.get("chats_count_application_id_" + application['id'].to_s).to_i + 1
        else
            count = Chat.where(application_id: application['id']).length
        end

        $redis.set("chats_count_application_id_" + application['id'].to_s, count)

        application.chats_count = count
        application.save
    end
    Rails.logger.info "Updated #{applications.length} Applications"
end


Rufus::Scheduler.singleton.every '1h' do
    chats = Chat.all
    chats.each do |chat|

        count = 0
        if $redis.get("messages_count_chat_id_" + chat['id'].to_s) != nil
            count = $redis.get("messages_count_chat_id_" + chat['id'].to_s).to_i + 1
        else
            count = Message.where(chat_id: chat['id']).length
        end

        $redis.set("messages_count_chat_id_" + chat['id'].to_s, count)


        chat.messages_count = count
        chat.save
    end
    Rails.logger.info "Updated #{chats.length} Chats"
end