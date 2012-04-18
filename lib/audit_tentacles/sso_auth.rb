class SSOAuth
  def self.get_cookies(url)
    h = {}
    agent = Mechanize.new
    agent.get(url) do |page|
      agent.submit(page.forms.first)
      agent.cookies.each do |c|
        h[c.name] = c.value
      end
    end
    h
  end
end
