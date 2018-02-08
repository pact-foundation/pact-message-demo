# TODO provider states

require 'json'

class Provider
  def a_test_message
    {
      text: "Hello world!!"
    }
  end
end

class Verifier
  def initialize provider
    @provider = provider
  end

  def verify message
    verification_method = message.description.downcase.gsub(' ', '_').to_sym
    message_content = @provider.send(verification_method)
    {content: message_content}
  end
end

class HttpRequestHandler

  def initialize verifier
    @verifier = verifier
  end

  def call env
    request_body = JSON.parse(env['rack.input'].read)
    message = OpenStruct.new(request_body)
    response_body = @verifier.verify(message)
    [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]
  end

end

run HttpRequestHandler.new(Verifier.new(Provider.new))
