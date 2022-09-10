class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.integer :number
      t.integer :application_id
      t.index [:application_id]

      t.timestamps
    end
  end
end
