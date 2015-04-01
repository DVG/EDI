class FakeSlack
  attr_accessor :socket
  def call(env)
    if Faye::WebSocket.websocket?(env)
      self.socket = Faye::WebSocket.new(env)

      socket.on :message do |event|
        socket.send(event.data)
      end

      socket.rack_response
    else
      [200, {'Content-Type' => 'text/plain'}, ['Hello']]
    end
  end
end
