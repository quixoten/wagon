require 'minitest_helper'

describe Wagon::Agent do
  def valid_agent
    Wagon::Agent.new("username", "valid_password")
  end

  def invalid_agent
    Wagon::Agent.new("username", "invalid_password")
  end

  before do
    stub_request(:post, Wagon::URL::LOGIN)
      .with(body: {username: "username", password: "valid_password"})
      .to_return(status: 200)

    stub_request(:post, Wagon::URL::LOGIN)
      .with(body: {username: "username", password: "invalid_password"})
      .to_return(status: 302)

    stub_request(:get, Wagon::URL::CURRENT_USER_ID)
      .to_return(status: 200, body: "1234567")

    stub_request(:get, Wagon::URL::CURRENT_USER_UNITS)
      .to_return(status: 200, body: File.new("test/response/current-user-units.json"))
  end

  describe ".new" do
    it "succeeds with a valid username and password" do
      valid_agent.must_be_instance_of Wagon::Agent
    end

    it "fails with an invalid username or password" do
      proc {
        invalid_agent
      }.must_raise Wagon::InvalidCredentials
    end
  end

  describe "#current_user_id" do
    it "returns a number identifying the current user" do
      valid_agent.current_user_id.must_equal "1234567"
    end
  end

  describe "#current_stake" do
    it "returns an instance of Wagon::Stake" do
      valid_agent.stake.must_be_instance_of Wagon::Stake
    end
  end
end
