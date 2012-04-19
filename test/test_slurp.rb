require './lib/audit_tentacles'
Bundler.require(:test)

require 'minitest/autorun'

class TestSlurp < MiniTest::Unit::TestCase
  def setup
    @o = Object.new
    @o.instance_variable_set(:@site, 'http://example.com')
    @doc = Nokogiri::HTML(File.new('./test/mocks/page.html'))
    @o.extend Slurp
  end


  def test_slurp_ignore_non_files
    a = @o.slurp(@doc)
    refute a.include? 'http://example.com/thing'
  end


  def test_slurp_ignores_external_paths
    a = @o.slurp(@doc)
    refute a.include? 'http://somesite.com/image3.jpg'
    refute a.include? 'http://somesite.com/image3.png'
    refute a.include? 'http://somesite.com/thing/thing3.zip'
  end


  def test_slurp_absolutes_relative_urls
    a = @o.slurp(@doc)
    assert a.include? 'http://example.com/image1.jpg'
    assert a.include? 'http://example.com/image1.png'
    assert a.include? 'http://example.com/thing/thing1.zip'
  end


  def test_slurp_finds_images
    a = @o.slurp(@doc)
    assert a.include? 'http://example.com/image1.jpg'
    assert a.include? 'http://example.com/image2.jpg'
    assert a.include? 'http://example.com/image1.png'
    assert a.include? 'http://example.com/image2.png'
  end


  def test_slurp_finds_docs
    a = @o.slurp(@doc)
    assert a.include? 'http://example.com/thing/thing1.pdf'
    assert a.include? 'http://example.com/thing/thing2.pdf'
    assert a.include? 'http://example.com/thing/thing1.zip'
    assert a.include? 'http://example.com/thing/thing2.zip'
  end


  def test_slurp_finds_videos
    a = @o.slurp(@doc)
    assert a.include? 'http://example.com/content/Video1.flv'
    assert a.include? 'http://example.com/content/Video2.flv'
  end
end
