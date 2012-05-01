class Output
  def initialize(file_path)
    @file_path = File.join(File.expand_path('~/'), file_path)
  end


  def hashes_with_sizes
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Hash', 'Bytes', 'Example location']
      $redis.smembers("#{$options.global_prefix}:sums").each do |k|
        size = $redis.get "#{$options.global_prefix}:#{k}:size"
        location = $redis.spop "#{$options.global_prefix}:#{k}:uris"
        csv << [k, size, location]
      end
    end
  end


  def basic
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Site', 'Bytes', 'Type', 'Location', 'URI', 'Location\'s MMS ID', 'MD5']
      $redis.smembers("#{$options.global_prefix}:uris").each do |k|
        sum = $redis.get "#{$options.global_prefix}:#{k}:sum"
        size = $redis.get "#{$options.global_prefix}:#{sum}:size"
        type = get_type(k)
        contexts = $redis.smembers "#{$options.global_prefix}:#{sum}:contexts"
        contexts.each do |context|
          site = get_site(context)
          id = MMS.id_for(context)
          csv << [site, size, type, context, k, id, sum]
        end
      end
    end
  end


  def get_type(uri)
    type = /\.(\w+)$/.match(uri)
    type = type[1] if type
    unless type
      type = 'flv'
    end
    type.downcase
  end


  def get_site(uri)
    norm_uri = uri.gsub('-', '_')
    site = /^http:\/\/(\w+(\.\w+)?)\.tki\.org\.nz/.match(norm_uri)
    site = site[1] if site
    site = 'portal' if site == 'www'
    site.downcase
  end
end
