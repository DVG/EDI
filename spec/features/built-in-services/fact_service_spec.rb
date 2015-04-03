require 'feature_spec_helper'
require 'socket'
require 'json'

def slack_message(message)
  {
      type: "message",
      channel: "C2147483705",
      user: "U2147483697",
      text: message,
      id: id
  }.to_json
end

def id
  @id ||= 0
  @id += 1
end

WebSocketSteps = RSpec::EM.async_steps do
  def server(port, backend, secure, &callback)
    @slack = FakeSlack.new
    @slack.listen(port, backend, secure)
    EM.add_timer(0.1, &callback)
  end

  def stop(&callback)
    @slack.stop
    EM.next_tick(&callback)
  end

  def connect_edi(url, &callback)
    done = false

    resume = lambda do |open|
      unless done
        done = true
        @open = open
        callback.call
      end
    end

    EDI.websocket(url: url).connect
    @edi = EDI.websocket.client
    @edi.on(:open) { |e| resume.call(true) }
    @edi.onclose = lambda { |e| resume.call(false) }
  end

  def disconnect_edi(&callback)
    @edi.onclose = lambda do |e|
      @edi = false
      callback.call
    end
    @edi.close
  end

  def check_open(&callback)
    expect(@open).to be(true)
    callback.call
  end

  def listen_for_message(&callback)
    @edi.add_event_listener('message', lambda { |e| @message = e.data })
    start = Time.now
    timer = EM.add_periodic_timer 0.1 do
      if @message or Time.now.to_i - start.to_i > 5
        EM.cancel_timer(timer)
        callback.call
      end
    end
  end

  def send_message(message, &callback)
    EM.add_timer(0.5) { @edi.send(slack_message(message)) }
    EM.next_tick(&callback)
  end

  def check_response(message, &callback)
    expect(@message).to eq(message)
    callback.call
  end

  def chatroom_has_message(message)
    expect(@slack).to have_message message
  end

  def check_no_response(&callback)
    expect(@message).to eq(nil)
    callback.call
  end

  def wait(seconds, &callback)
    EM.add_timer(seconds, &callback)
  end

end

describe "EDI Fact" do
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
    connect_edi url
    send_message "EDI, fact"
    listen_for_message
    listen_for_message
    chatroom_has_message "183"
  end
end
