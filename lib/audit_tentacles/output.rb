class Output
  def initialize(file_path)
    @file_path = File.join(File.dirname(__FILE__), file_path)
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
end
