require './lib/audit_tentacles'
Bundler.require(:test)

require 'minitest/autorun'
require 'webmock/minitest'

class TestMedia < MiniTest::Unit::TestCase
  def setup
    $redis = MockRedis.new
    img = File.open('./test/mocks/cat1.jpg')
    stub_request(:get, "http://example.com/media/thing.jpg").to_return({:status => 200, :body => img})
    img = File.open('./test/mocks/cat2.jpg')
    stub_request(:get, "http://example.com/media/another.jpg").to_return({:status => 200, :body => img})
    solr_null = File.open('./test/mocks/solr_null')
    stub_request(:any, /#{Regexp.escape($options.solr)}\/select/).to_return({:status => 200, :body => solr_null})
  end


  def teardown
    load './lib/audit_tentacles/redis.rb'
  end


  def test_item_saved
    sum = Media.log('http://example.com/media/thing.jpg', 'http://example.com/page')
    assert_equal sum, $redis.smembers("#{$options.global_prefix}:sums").first
    uri = $redis.smembers("#{$options.global_prefix}:uris").first
    assert_equal 'http://example.com/media/thing.jpg', uri
    assert_equal sum, $redis.get("#{$options.global_prefix}:#{uri}:sum")
    assert_equal 'http://example.com/page', $redis.smembers("#{$options.global_prefix}:#{sum}:contexts").first
    assert_equal 'http://example.com/media/thing.jpg', $redis.smembers("#{$options.global_prefix}:#{sum}:uris").first
    assert_equal '444808', $redis.get("#{$options.global_prefix}:#{sum}:size")
  end


  def test_identical_files_have_same_sum
    sum1 = Media.log('http://example.com/media/thing.jpg', 'http://example.com/page')
    sum2 = Media.log('http://example.com/media/another.jpg', 'http://example.com/page')
    assert_equal sum1, sum2
  end


  def test_flush_kills_all_keys
    sum1 = Media.log('http://example.com/media/thing.jpg', 'http://example.com/page')
    sum2 = Media.log('http://example.com/media/another.jpg', 'http://example.com/page')
    Media.flush
    refute $redis.exists("#{$options.global_prefix}:sums")
    refute $redis.exists("#{$options.global_prefix}:uris")
    refute $redis.get("#{$options.global_prefix}:http://example.com/media/thing.jpg:sum")
    refute $redis.get("#{$options.global_prefix}:http://example.com/media/another.jpg:sum")
    refute $redis.exists("#{$options.global_prefix}:#{sum1}:contexts")
    refute $redis.exists("#{$options.global_prefix}:#{sum2}:contexts")
    refute $redis.exists("#{$options.global_prefix}:#{sum1}:uris")
    refute $redis.exists("#{$options.global_prefix}:#{sum2}:uris")
    refute $redis.exists("#{$options.global_prefix}:#{sum1}:size")
    refute $redis.exists("#{$options.global_prefix}:#{sum2}:size")
  end
end
