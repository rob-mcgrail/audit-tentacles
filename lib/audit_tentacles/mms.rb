class MMS
  def self.id_for(uri)
    id = nil#$redis.get "#{$options.global_prefix}:context:#{uri}:id"
    unless id
      id = self.find(uri)
      $redis.set "#{$options.global_prefix}:context:#{uri}:id", id
    end
    id
  end


 class << self
    alias_method :store_id_for, :id_for
  end


  def self.find(uri)
    solr = RSolr.connect :url => $options.solr
    begin
      response = solr.get 'select', :params => {:q => '*:*', :fq => "{!field f=url}#{uri}"}
    rescue Errno::ECONNRESET
      retry
    end
    if response["response"]["numFound"] > 0
      id = response["response"]["docs"].first["id"]
      if id =~ /TKI\d+/
        id
      else
        nil
      end
    else
      nil
    end
  end

end
