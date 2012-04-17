class Media
    @@prefix = {
      :context => "#{$options.global_prefix}:context:",
      :uri => "#{$options.global_prefix}:uri:",
      :sums => "#{$options.global_prefix}:sums:",
      :contexts => "#{$options.global_prefix}:contexts:",
      :uris => "#{$options.global_prefix}:uris:",
    }

  def self.log(uri, context)
    # get file uri
    # make checksum
    $redis.sadd "#{$options.global_prefix}:sums:" sum
    $redis.set "#{$options.global_prefix}:#{sum}:size" size
    $redis.sadd "#{$options.global_prefix}:#{sum}:contexts" context
    $redis.sadd "#{$options.global_prefix}:uris" uri
    $redis.sadd "#{$options.global_prefix}:contexts" context
  end

  private

  def flush_sets(setpairs)
    setpairs.each do |superset, set_prefix|
      keys = $redis.smembers superset
      keys.each do |k|
        $redis.del set_prefix + ":#{k}"
      end
      $redis.del superset
    end
  end
end
