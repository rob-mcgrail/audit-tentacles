class Output
  def initialize(file_path)
    @file_path = File.join(File.expand_path('~/'), file_path)
  end


  def sizes_for_media_by_uri
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Type', 'Bytes']
      counts = {}
      $redis.smembers("#{$options.global_prefix}:uris").each do |k|
        sum = $redis.get "#{$options.global_prefix}:#{k}:sum"
        size = $redis.get "#{$options.global_prefix}:#{sum}:size"
        type = get_type(k)

        if counts[type]
          counts[type] += size.to_i
        else
          counts[type] = 0
          counts[type] += size.to_i
        end
      end
      counts.each do |k,v|
        csv << [k, v]
      end
    end
  end


  def sizes_for_media_by_ezp
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Type', 'Bytes']
      counts = {}
      $redis.smembers("#{$options.global_prefix}:ezps").each do |k|
        sum = $redis.get "#{$options.global_prefix}:#{k}:sum"
        size = $redis.get "#{$options.global_prefix}:#{sum}:size"
        type = get_type(k)

        if counts[type]
          counts[type] += size.to_i
        else
          counts[type] = 0
          counts[type] += size.to_i
        end
      end
      counts.each do |k,v|
        csv << [k, v]
      end
    end
  end


  def basic
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Site', 'Bytes', 'Type', 'Location', 'URI',  'EzPub Location', 'Location\'s MMS ID', 'MD5']

      $redis.smembers("#{$options.global_prefix}:uris").each do |k|
        sum = $redis.get "#{$options.global_prefix}:#{k}:sum"
        size = $redis.get "#{$options.global_prefix}:#{sum}:size"
        type = get_type(k)

        contexts = $redis.smembers "#{$options.global_prefix}:#{sum}:contexts"

        contexts.each do |context|
          site = get_site(context)
          id = MMS.id_for(context)
          ezp = EzPub.media_node_for(k)
          a = [site, size, type, context, k, ezp, id, sum]

          puts $term.color(a.to_s, :green)

          csv << a
        end
      end
    end
  end


  def basic_with_single_contexts
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Site', 'Bytes', 'Type', 'Example Context', 'URI',  'Example EzPub Location', 'Example Context MMS ID', 'MD5']

      $redis.smembers("#{$options.global_prefix}:uris").each do |k|
        sum = $redis.get "#{$options.global_prefix}:#{k}:sum"
        size = $redis.get "#{$options.global_prefix}:#{sum}:size"
        type = get_type(k)

        contexts = $redis.smembers "#{$options.global_prefix}:#{sum}:contexts"

        example_context = nil
        ezp = nil
        mms_id = nil

        contexts.each do |context|
          mms_id = MMS.id_for(context) if MMS.id_for(context)
          ezp = EzPub.media_node_for(k) if EzPub.media_node_for(k)
          example_context = context
        end

        site = get_site(contexts.first)

        a = [site, size, type, example_context, k, ezp, mms_id, sum]

        puts $term.color(a.to_s, :green)

        csv << a
      end
    end
  end


  def crosssite
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Sum', 'Contexts', 'Sites', 'Type', 'URI', 'Context example']
      $redis.smembers("#{$options.global_prefix}:sums").each do |k|
        contexts = $redis.smembers "#{$options.global_prefix}:#{k}:contexts"

        contexts.each do |c|
          $redis.sadd "#{$options.global_prefix}:#{k}:sites", get_site(c)
        end

        sites = $redis.scard "#{$options.global_prefix}:#{k}:sites"

        uris = $redis.smembers "#{$options.global_prefix}:#{k}:uris"

        uri = uris[0]

        type = get_type(uri)

        context = contexts[0]

        csv << [k, contexts.length, sites, type, uri, context]
      end
    end
  end


  def meaningful_uniques
    blacklistable_uniques do |type|
       ['jpg', 'png', 'gif', 'mp3'].include? type
    end
  end


  def cruft_uniques
    blacklistable_uniques do |type|
       !['jpg', 'png', 'gif', 'mp3'].include? type
    end
  end


  def blacklistable_uniques
    FasterCSV.open(@file_path, "w") do |csv|
      csv << ['Site', 'Type', 'EzPub Location', 'Sums', 'Bytes', 'Example URI', 'URIs', 'Example context page', 'Context pages', 'Example context-page MMS record']

      $redis.del "#{$options.global_prefix}:ezps"

      $redis.smembers("#{$options.global_prefix}:sums").each do |k|
        uri = $redis.srandmember "#{$options.global_prefix}:#{k}:uris"
        uri_count = $redis.scard "#{$options.global_prefix}:#{k}:uris"
        type = get_type(uri)

        blacklist = yield type

        unless blacklist
          ezp = EzPub.media_node_for(uri)

          $redis.sadd "#{$options.global_prefix}:ezps", ezp

          unless $redis.sismember "#{$options.global_prefix}:ezps", ezp

            $redis.sadd "#{$options.global_prefix}:#{ezp}:sums", k

            size = $redis.get "#{$options.global_prefix}:#{k}:size"
            context = $redis.srandmember "#{$options.global_prefix}:#{k}:contexts"
            context_count = $redis.scard "#{$options.global_prefix}:#{k}:contexts"
            contexts = $redis.smembers "#{$options.global_prefix}:#{k}:contexts"
            mms_id = nil

            contexts.each do |context|
              id = MMS.id_for(context)
              mms_id = id if id
            end

            site = get_site(context)
            sums = $redis.scard "#{$options.global_prefix}:#{ezp}:sums"

            a = [site, type, ezp, sums, size, uri, uri_count, context, context_count, mms_id]

            puts $term.color(a.to_s, :green)

            csv << a
          end
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


  def tidyup
    $redis.smembers("#{$options.global_prefix}:uris").each do |k|
      sum = $redis.get("#{$options.global_prefix}:#{k}:sum")
      $redis.sadd "#{$options.global_prefix}:#{sum}:uris", k
    end
  end
end
