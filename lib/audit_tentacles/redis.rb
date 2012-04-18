$redis = Redis.new

$redis.select $options.datastore
