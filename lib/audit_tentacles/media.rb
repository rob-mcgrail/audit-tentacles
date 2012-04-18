class Media
  def self.log(uri, context)
    unless $redis.sismember "#{$options.global_prefix}:uris", uri
      info = file_info(uri)
      puts $term.color("To redis...", :blue)
      $redis.multi do
        $redis.sadd "#{$options.global_prefix}:sums", info[:sum]
        $redis.set "#{$options.global_prefix}:#{info[:sum]}:size", info[:size]
        $redis.sadd "#{$options.global_prefix}:#{info[:sum]}:contexts", context
        $redis.sadd "#{$options.global_prefix}:#{info[:sum]}:uris", uri
        $redis.sadd "#{$options.global_prefix}:uris", uri
        $redis.set "#{$options.global_prefix}:#{uri}:sum", info[:sum]
      end
      info[:sum]
    end
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
    print $term.color("Hashing...", :blue)
    require 'digest/md5'
    Digest::MD5.hexdigest(file.read)
  end


  def self.get_file(uri)
    require 'uri'
    require 'open-uri'
    uri = URI.escape(uri)
    uri.gsub!('[', '%5B')
    uri.gsub!(']', '%5D')
    open(uri)
  end


  def self.flush
    keys = $redis.smembers "#{$options.global_prefix}:sums"
    keys.each do |k|
      $redis.del "#{$options.global_prefix}:#{k}:size"
      $redis.del "#{$options.global_prefix}:#{k}:contexts"
      $redis.del "#{$options.global_prefix}:#{k}:uris"
    end
    keys = $redis.smembers "#{$options.global_prefix}:uris"
    keys.each do |k|
      $redis.del "#{$options.global_prefix}:#{k}:sum"
    end
    $redis.del "#{$options.global_prefix}:uris"
    $redis.del "#{$options.global_prefix}:sums"
  end
end
