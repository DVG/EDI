require 'edi'
require 'cucumber'
require 'faye/websocket'
require 'rack'
require 'byebug'
require 'cucumber/rspec/doubles'
require_relative './slack_manager'
require 'vcr'
require 'webmock/cucumber'

Before do
  @slack = FakeSlack.new
  stub_request(:get, "https://slack.com/api/rtm.start?token=#{ENV["SLACK_EDI_TOKEN"]}").
    to_return(:status => 200, :body => json_response("slack_connection"), :headers => {})
  stub_request(:any, "ws://localhost:9292").to_rack(@slack)
  @edi_thread = Thread.new do
    EDI.websocket.connect
  end
  sleep 1
end

def json_response(file_name)
  File.open(File.dirname(__FILE__) + '/fixtures/' + file_name + ".json", 'rb').read
end

VCR.configure do |config|
  config.cassette_library_dir = "features/support/fixtures/vcr_cassettes"
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
end

VCR.cucumber_tags do |t|
  t.tag  '@vcr', :use_scenario_name => true
end

at_exit do
  EventMachine.stop
end
