class EzPub
  def self.media_node_for(uri)
    ezp = $redis.get "#{$options.global_prefix}:uri:#{uri}:ezp"
    unless ezp
      ezp = self.from_storage(uri) || self.from_content(uri) || 'Unkown'
      $redis.set "#{$options.global_prefix}:uri:#{uri}:ezp", ezp
    end
    ezp
  end


  def self.from_storage(uri)
    domain = 'http://admin.' + domain_match(uri)
    path_match = /\/var\/[\w|-]+\/storage\/[\w|-]+(\/(media|video-gallery)\/([\w|\d|\.|\_|-]+\/)+)/.match(uri)
    if path_match
      domain + path_match[1].sub(/\/[^\/]+\/$/, '')
    else
      nil
    end
  end

  # add in other pattern?

  def self.from_content(uri)
    domain = domain_match(uri)
    id_match = /\w+\/\w+\/(\d+\/\d+)/.match(uri)
    if id_match
      ids = id_match[1].split('/')
      domain + " object:#{ids[0]} attr:#{ids[1]}"
    else
      nil
    end
  end


  def self.domain_match(uri)
    domain_match = /^http:\/\/([^\/]+)/.match(uri)
    domain_match[1] if domain_match
  end
end
