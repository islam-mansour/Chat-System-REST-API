Rails.application.routes.draw do
  apipie
  namespace 'api' do
    namespace 'v1' do
      resources :applications
      get '/applications/:token/chats', to: 'applications#chats'

      resources :chats
      get '/applications/:token/chats/:number/messages', to: 'chats#messages'


      resources :messages
      post '/messages/search', to: 'messages#search'

    end
  end
end
