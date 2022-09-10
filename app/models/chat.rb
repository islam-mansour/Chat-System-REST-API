class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages

  add_index :application, :application_id

end
