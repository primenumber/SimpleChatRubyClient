require 'websocket-client-simple'
require 'json'

class SimpleChatClient
  attr_reader :user
  def initialize(uri)
    @ws =  WebSocket::Client::Simple.connect uri
  end

  def init(id)
    @ws.send(JSON.generate({
      'type' => 'get_user_data',
      'id' => id
    }))
  end

  def onlogin
    @ws.on :message do |json|
      obj = JSON.parse(json.to_s)
      if obj['type'] == 'self_user_data' then
        @user = obj['user']
        yield(@user)
      end
    end
  end

  def send_message(message, tags)
    @ws.send(JSON.generate({
      'type' => 'broadcast',
      'message' => message,
      'tags' => tags
    }))
  end

  def onmessage
    @ws.on :message do |json|
      obj = JSON.parse(json.to_s)
      if obj['type'] == 'broadcast' then
        yield(obj['name'], obj['message'], 'broadcast', obj['tags'])
      end
    end
  end

  def onerror
    @ws.on :message do |json|
      obj = JSON.parse(json.to_s)
      if obj['type'] == 'error' then
        yield(obj['message'])
      end
    end
  end

  def onconnect
    @ws.on :open do
      yield
    end
  end

  def onclose
    @ws.on :close do
      yield
    end
  end
end
