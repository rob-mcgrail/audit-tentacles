class MMS
  def self.id_for(uri)
    id = $redis.get "#{$options.global_prefix}:context:#{uri}:id"
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
    response = solr.get 'select', :params => {:q => '*:*', :fq => "{!field f=url}#{uri}"}
    if response["response"]
      response["response"]["docs"].first["id"]
    else
      nil
    end
  end
end
