class Crawler
  include Slurp

  def initialize(site)
    @site = site
    @site.gsub!(/\/$/, '')
  end


  def crawl
    opts = {
      :discard_page_bodies => true,
      :delay => $options.page_delay,
      :redirect_limit => 1,
      :depth_limit => 12,
      :accept_cookies => true,
      :cookies => SSOAuth.get_cookies(@site),
      :skip_query_strings => true,
    }
    pre_cleanup
    Anemone.crawl(@site, opts) do |anemone|
      anemone.skip_links_like /%23/ # anemone was confused by links like: /News#123
      anemone.on_every_page do |page|
        links = slurp(page) if page.doc
        if links
          links.each do |link|
            begin
              puts $term.color("Logging #{link}", :green)
              Media.log link, page.url
            rescue Timeout::Error, Errno::ECONNRESET, SocketError, URI::InvalidURIError => e
              puts $term.color(e.message, :red)
            end
          end
        end
      end
    end
    post_cleanup
  end


  private


  def pre_cleanup
  end


  def post_cleanup
  end
end
