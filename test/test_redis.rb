require './lib/tki-linkcheck'
Bundler.require(:test)

require 'minitest/autorun'

class TestRedis < MiniTest::Unit::TestCase
  def test_redis_constant_exists
    assert_kind_of Redis, $redis
  end


  def test_sever_responding
    assert_equal 'PONG', $redis.ping
  end
end
