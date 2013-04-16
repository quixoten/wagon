require 'wagon'

require 'minitest/autorun'
require 'minitest/pride'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.default_cassette_options = {
    record: :new_episodes, match_requests_on: [:uri, :host, :body]
  }
end
