require 'spec_helper'

describe Wagon::User, :class do
  let(:req_mock) {
    lambda do |*|
      mock = Minitest::Mock.new
      mock.expect(:send_with_cookies!, true, [nil])
    end
  }

  describe ".new" do
    it "makes a login request" do
      Wagon::Request::Login.stub(:new, req_mock) do
        assert(Wagon::User.new("username", "password"))
      end
    end
  end
end
