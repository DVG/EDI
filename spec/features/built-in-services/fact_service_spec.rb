require 'feature_spec_helper'
require 'socket'
require 'json'

RSpec.describe "Fact", vcr: { cassette_name: 'fact' } do
  include WebSocketSteps

  before do
    stub_request(:get, "https://slack.com/api/rtm.start?token=").
      to_return(:status => 200, :body => json_response("slack_connection"), :headers => {})
  end

  before { server port, :thin, true }
  before { EDI.register_services :fact }
  after  { stop }
  let(:port)  { 4180 }
  let(:url)   { "ws://localhost:#{port}"}
  it "can conncet" do
    connect_edi url
    check_open
  end

  it "responds with a fact" do
    connect_client url
    connect_edi url
    send_message "EDI, fact"
    edi_listen_for_message
    slack_listen_for_message
    chatroom_has_message "183"
  end
end
