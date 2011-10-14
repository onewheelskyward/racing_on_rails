require "minitest/autorun"
require File.expand_path("../../../lib/test/enumerable_assertions", __FILE__)
require "active_support/concern"
require "mocha"

class NoRailsTestCase < MiniTest::Unit::TestCase
  include EnumerableAssertions
end
