#untill rebitmq instance is up so that workers doesn't throw connection error
bash -c "sleep 10"

bash -c "cd /app/app/workers/ && ruby messages.rb &!"
bash -c "cd /app/app/workers/ && ruby chats.rb &!"

bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"