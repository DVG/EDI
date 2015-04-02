class FakeSlack
  attr_accessor :socket, :messages

  def initialize
    @messages = []
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      self.socket = Faye::WebSocket.new(env)

      socket.on :open do |event|
        puts "Client Connected"
      end

      socket.on :message do |event|
        puts "Message Received"
        @messages << event.data
        socket.send(event.data)
      end

      socket.rack_response
    else
      [200, {'Content-Type' => 'text/plain'}, ['Hello']]
    end
  end

  def has_message?(message)
    puts "Checking Slack for message #{message}"
    puts "Messages: #{messages}"
    messages.include? message
  end
end
