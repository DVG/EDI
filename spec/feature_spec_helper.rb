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

EDI.configure do |config|
  config.log_level = :silent
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

  def connect_client(url, &callback)
    done = false

    resume = lambda do |open|
      unless done
        done = true
        @client_open = open
        callback.call
      end
    end
    @client = Faye::WebSocket::Client.new(url)
    @client.on(:open) { |e| resume.call(true) }
    @client.onclose = lambda { |e| resume.call(false) }
  end

  def connect_edi(url, &callback)
    done = false

    resume = lambda do |open|
      unless done
        done = true
        @edi_open = open
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
    expect(@edi_open).to be(true)
    callback.call
  end

  def edi_listen_for_message(&callback)
    message = nil
    @edi.add_event_listener('message', lambda do |e|
      message = e.data
    end)
    start = Time.now
    timer = EM.add_periodic_timer 0.1 do
      if message or Time.now.to_i - start.to_i > 5
        EM.cancel_timer(timer)
        callback.call
      end
    end
  end

  def slack_listen_for_message(&callback)
    message = nil
    @slack.socket.add_event_listener('message', lambda do |e|
      message = e.data
    end)
    start = Time.now
    timer = EM.add_periodic_timer 0.1 do
      if message or Time.now.to_i - start.to_i > 5
        EM.cancel_timer(timer)
        callback.call
      end
    end
  end

  def send_message(message, &callback)
    EM.add_timer(0.5) { @client.send(slack_message(message)) }
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
