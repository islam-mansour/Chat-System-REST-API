require 'elasticsearch/model'

class Message < ApplicationRecord
  belongs_to :chat

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: {number_of_shards: 1} do
    mapping dynamic: 'false' do
      indexes :body, type: :text
    end
  end

end
