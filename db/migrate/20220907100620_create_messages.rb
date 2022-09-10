class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :number
      t.integer :chat_id
      t.index [:chat_id]
      t.text :body

      t.timestamps
    end
  end
end
