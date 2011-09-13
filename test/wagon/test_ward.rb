require 'helper'

class TestWagonUser < Test::Unit::TestCase
  def test_name
    assert_not_nil(user.ward.name)
  end

  def test_households
    puts user.ward.households.size
    assert_not_nil(user.ward.households)
  end
end

