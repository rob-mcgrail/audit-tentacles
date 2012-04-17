#class Crawler
#  def initialize(site)
#    @site = site
#  end


#  def crawl
#    opts = {
#      :discard_page_bodies => true,
#      :delay => $options.page_delay,
#      :redirect_limit => 1,
#      :depth_limit => 12,
#      :accept_cookies => true,
#      :cookies => SSOAuth.get_cookies(@site.location),
#    }
#    LinkCache.flush # only cleared if not recently used
#    pre_cleanup
#    Anemone.crawl(@site.location, opts) do |anemone|
#      @site.log_crawl
#      anemone.skip_links_like /%23/ # anemone was confused by links like: /News#123
#      anemone.on_every_page do |page|
#        check_links(page) if page.doc
#        @site.log_page page.url
#      end
#    end
#    post_cleanup
#  end


#  private

#  def check_links(page)
#    links = extract_links(page)
#    links.each do |link|
#      unless LinkCache.passed? link
#        check = Check.new
#        problem = check.validate(page, link)
#        puts problem # remove
#        if problem
#          @site.add_broken page.url, link, problem
#        end
#        LinkCache.add link
#        @site.log_link link
#      end
#    end
#  end


#  def extract_links(page)
#    require 'uri'
#    a = page.doc.css('a')
#    a = a.map {|link| link.attribute('href').to_s}
#    a = filter_urls(a, page)
#    a = clean_urls(a, page)
#    a
#  end


#  def clean_urls(a, page)
#    a.map! do |link|
#      if link !~ /^[a-z]+:\/\// # doesn't start with a protocol
#        if link =~ /^\// # does start with a slash
#          location = "http://#{page.url.host}/"
#          link = location + link.gsub(/^\//,'') # make absolute
#        else
#          # remove last portion of url
#          url = page.url.to_s
#          chop = /([^\/]+$)/.match(url).to_s
#          i = -chop.length-1
#          url = url[0..i]
#          # append relative url
#          link = url + link.gsub(/^\//,'') # make absolute
#        end
#      else
#        link
#      end
#      link = link.gsub('%23', '#')
#    end
#    a
#  end


#  def filter_urls(a, page)
#    a.uniq!
#    a.delete_if do |link|
#      outcome = nil
#      $options.permanently_ignore.each do |match|
#        outcome = link =~ match
#      end
#      outcome
#    end
#    a = [] if page.doc.at_xpath("//base") # because, really guys?
#    a
#  end


#  def pre_cleanup
#    @site.reset_counters
#    @site.flush_temp_blacklist
#    @site.flush_issues
#  end


#  def post_cleanup
#  end
#end
