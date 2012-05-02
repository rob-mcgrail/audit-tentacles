class EzPub
  def self.media_node_for(uri)
    ezp = nil#$redis.get "#{$options.global_prefix}:uri:#{uri}:ezp"
    unless ezp
      ezp = self.from_storage(uri) || self.from_content(uri)
      $redis.set "#{$options.global_prefix}:uri:#{uri}:ezp", ezp
    end
    ezp
  end


  def self.from_storage(uri)
    domain = domain_match(uri)
    path_match = /\/var\/[\w|-]+\/storage\/[\w|-]+(\/media\/([\w|\d|-]+\/)+)/.match(uri)
    if path_match
      domain + path_match[1].sub(/\/[^\/]+\/$/, '')
    else
      nil
    end
  end


  def self.from_content(uri)
    domain = domain_match(uri)
    id_match = /content\/download\/(\d+\/\d+)/.match(uri)
    if id_match
      ids = id_match[1].split('/')
      domain + " object:#{ids[0]} attr:#{ids[1]}"
    else
      nil
    end
  end


  def self.domain_match(uri)
    domain_match = /^http:\/\/([^\/]+)/.match(uri)
    'http://admin.' + domain_match[1]
  end
end
