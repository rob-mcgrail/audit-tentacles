require './lib/audit-tentacles'
Bundler.require(:test)

require 'minitest/autorun'

class TestSite < MiniTest::Unit::TestCase
  def setup
    $redis = MockRedis.new
  end


  def teardown
    load './lib/audit-tentacles/redis.rb'
  end
end
