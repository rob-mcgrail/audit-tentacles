class Media
  def self.log(uri, context)
    info = file_info(uri)
    $redis.multi do
      $redis.sadd "#{$options.global_prefix}:sums", info[:sum]
      $redis.hset "#{$options.global_prefix}:#{info[:sum]}", 'uri', uri
      $redis.hset "#{$options.global_prefix}:#{info[:sum]}", 'context', context
      $redis.hset "#{$options.global_prefix}:#{info[:sum]}", 'size', info[:size]
      $redis.sadd "#{$options.global_prefix}:uris", uri
      $redis.sadd "#{$options.global_prefix}:contexts", context
    end
    info[:sum]
  end

  private

  def self.file_info(uri)
    info = {}
    file = get_file(uri)
    info[:size] = file.size
    info[:sum] = hash_file(file)
    info
  end


  def self.hash_file(file)
    require 'digest/md5'
    Digest::MD5.hexdigest(file.read)
  end


  def self.get_file(uri)
    require 'open-uri'
    open(uri)
  end


  def self.flush_sets(setpairs)
    setpairs.each do |superset, set_prefix|
      keys = $redis.smembers superset
      keys.each do |k|
        $redis.del set_prefix + ":#{k}"
      end
      $redis.del superset
    end
  end
end
