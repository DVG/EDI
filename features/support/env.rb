require 'edi'
require 'cucumber'
require 'faye/websocket'
require 'rack'
require 'byebug'
require 'cucumber/rspec/doubles'
require_relative './slack_manager'
require 'webmock/cucumber'

Before do
  stub_request(:get, "https://slack.com/api/rtm.start?token=").
    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => json_response("slack_connection"), :headers => {})
  @manager = SlackManager.new
  @manager.start_stack
end



def json_response(file_name)
  File.open(File.dirname(__FILE__) + '/fixtures/' + file_name + ".json", 'rb').read
end
