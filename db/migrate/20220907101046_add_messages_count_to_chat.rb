class AddMessagesCountToChat < ActiveRecord::Migration[5.2]
  def change
    add_column :chats, :messages_count, :integer
  end
end
