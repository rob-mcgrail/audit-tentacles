require './lib/audit_tentacles'
Bundler.require(:test)

require 'minitest/autorun'
require 'webmock/minitest'

class TestMedia < MiniTest::Unit::TestCase
  def setup
    $redis = MockRedis.new
    img = File.open('./test/mocks/cat1.jpg')
    stub_request(:get, "example.com/media/thing.jpg").to_return({:status => 200, :body => img})
    img = File.open('./test/mocks/cat2.jpg')
    stub_request(:get, "example.com/media/another.jpg").to_return({:status => 200, :body => img})
  end


  def teardown
    load './lib/audit_tentacles/redis.rb'
  end


  def test_item_saved
    sum = Media.log('http://example.com/media/thing.jpg', 'http://example.com/page')
    assert_equal sum, $redis.smembers("#{$options.global_prefix}:sums").first
    assert_equal 'http://example.com/media/thing.jpg', $redis.smembers("#{$options.global_prefix}:uris").first
    assert_equal 'http://example.com/page', $redis.smembers("#{$options.global_prefix}:contexts").first

    h = $redis.hgetall("#{$options.global_prefix}:#{sum}")
    assert_equal '444808', h['size']
    assert_equal 'http://example.com/media/thing.jpg', h['uri']
    assert_equal 'http://example.com/page', h['context']
  end


  def test_identical_files_have_same_sum
    sum1 = Media.log('http://example.com/media/thing.jpg', 'http://example.com/page')
    sum2 = Media.log('http://example.com/media/another.jpg', 'http://example.com/page')
    assert_equal sum1, sum2
  end
end
