require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new(hosts: 'elasticsearch:9200')    
