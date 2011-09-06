require 'helper'
require 'highline'

class TestWagonUser < Test::Unit::TestCase
  def test_user
    hl = HighLine.new

    username = hl.ask("lds.org username: ")
    password = hl.ask("lds.org password: ") { |q| q.echo = "*" }

    @user = Wagon::User.new(username, password)
  end
end

