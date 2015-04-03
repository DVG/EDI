require 'rspec'
require 'edi'
require 'byebug'
require 'vcr'
require 'support/fake_slack'
require 'rspec/em'
require 'webmock/rspec'

def json_response(file_name)
  File.open(File.dirname(__FILE__) + '/support/fixtures/' + file_name + ".json", 'rb').read
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/support/fixtures/vcr_cassettes"
  config.configure_rspec_metadata!
  config.hook_into :webmock
  config.filter_sensitive_data("<SLACK_EDI_TOKEN>") { ENV["SLACK_EDI_TOKEN"] }
  config.filter_sensitive_data("<DEFAULT_LOCATION>") { ENV["DEFAULT_LOCATION"] }
  config.filter_sensitive_data("IMGFLIP_USER") { ENV["IMGFLIP_USER"] }
  config.filter_sensitive_data("IMGFLIP_PASSWORD") { ENV["IMGFLIP_PASSWORD"] }
  config.filter_sensitive_data("SLACK_TOKEN") { ENV["SLACK_TOKEN"] }
  config.filter_sensitive_data("GIPHY_API_KEY") { ENV["GIPHY_API_KEY"] }
  config.filter_sensitive_data("GIPHY_API_VERSION") { ENV["GIPHY_API_VERSION"] }
  config.filter_sensitive_data("TWITTER_ACCESS_TOKEN") { ENV["TWITTER_ACCESS_TOKEN"] }
  config.filter_sensitive_data("TWITTER_CONSUMER_KEY") { ENV["TWITTER_CONSUMER_KEY"] }
  config.filter_sensitive_data("TWITTER_CONSUMER_SECRET") { ENV["TWITTER_CONSUMER_SECRET"] }
  config.filter_sensitive_data("TWITTER_HANDLE") { ENV["TWITTER_HANDLE"] }
  config.filter_sensitive_data("TWITTER_TOKEN_SECRET") { ENV["TWITTER_TOKEN_SECRET"] }
  config.allow_http_connections_when_no_cassette = true
end
