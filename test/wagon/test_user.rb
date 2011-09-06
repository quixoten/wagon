require 'helper'

class TestWagonUser < Test::Unit::TestCase
  def test_user
    assert_raise(Wagon::AuthenticationFailure) do
      Wagon::User.new("fakeUser", "fakePassword")
    end

    assert(user.is_a?(Wagon::User))
  end

  def test_ward_and_stake
    assert_not_nil(user.ward_and_stake)
    assert_not_nil(user.ward_and_stake["wardUnitNo"])
  end
end

