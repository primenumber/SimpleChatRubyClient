require 'websocket-client-simple'
require 'json'

class SimpleChatClient
  attr_reader :user
  def initialize(uri)
    @ws =  WebSocket::Client::Simple.connect uri

    @ws.on :message do |json|
      obj = JSON.parse(json)
      case obj['type']
      when 'self_user_data' then
        @user = obj['user']
      when 'error' then
        onerror obj['message']
      when 'broadcast' then
        @onmsg_block.call(obj['name'], obj['message'], 'broadcast', obj['tags'])
      end
    end

    @ws.on :open do
      onconnect
    end

    @ws.on :close do
      onclose
    end
  end

  def init(id)
    @ws.send(JSON.generate({
      'type' => 'get_user_data',
      'id' => id
    }))
  end

  def send_message(message, tags)
    @ws.send(JSON.generate({
      'type' => 'broadcast',
      'message' => message,
      'tags' => tags
    }))
  end

  def onmessage(&block)
    @onmsg_block = block
  end

  def onerror(message)
    yield message
  end

  def onconnect
    yield
  end

  def onclose
    yield
  end
end
