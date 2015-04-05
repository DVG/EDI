require 'rack'
class FakeSlack
  Faye::WebSocket.load_adapter('thin')
  Thin::Logging.silent = true
  attr_accessor :socket, :messages

  def initialize
    @messages = []
  end

  def call(env)
    self.socket = Faye::WebSocket.new(env, ["echo"])
    socket.onmessage =  lambda do |event|
      @messages << Slack::WebsocketIncomingMessage.new(event.data)
      socket.send(event.data)
    end
    socket.rack_response
  end

  def log(*args)
  end

  def listen(port, backend, tls = false)
    listen_thin(port, tls)
  end

  def stop
    @messages = []
    @server.stop
  end

  def has_message?(message)
    debugger
    messages.find_all { |m| m.text == message}.any?
  end

private
  def listen_thin(port, tls)
    Rack::Handler.get('thin').run(self, :Port => port) do |s|
      @server = s
    end
  end
end
