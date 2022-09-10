$redis = Redis::Namespace.new("", redis: Redis.new({host: 'redis', password: 'redis-secret'}))
