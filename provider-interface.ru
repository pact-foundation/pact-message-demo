# TODO Producer states
require 'json'

# This class handles the incoming request from the pact-provider-verifier,
# and delegates it to the MessageInvoker
# This class would be written by the pact-message maintainer
class HttpRequestHandler

  def initialize message_invoker
    @message_invoker = message_invoker
  end

  # Handle the request
  def call env
    request_body = JSON.parse(env['rack.input'].read)
    message_descriptor = parse_request(request_body)
    message_contents = @message_invoker.invoke(message_descriptor)
    response_body = {contents: message_contents}
    [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]
  rescue StandardError => e
    [500, {'Content-Type' => 'application/json'}, [{error: e.message}.to_json]]
  end

  # Turn raw Ruby hashes into Ruby objects
  def parse_request request_body
    provider_states = request_body['providerStates'].collect{ | provider_state| OpenStruct.new(provider_state) }
    OpenStruct.new(
      description: request_body['description'],
      provider_states: provider_states)
  end
end


# This is the producer we will be testing
# This class would be written by the producer team
class HelloProducerService
  def hello_message alligator
    {
      text: "Hello #{alligator.name}!!"
    }
  end
end

class GoodbyeProducerService
  def goodbye_message alligator
    {
      text: "Goodbye #{alligator.name}!!"
    }
  end
end

# Domain class. This would be written by the producer team
class Alligator
  attr_accessor :name

  def initialize name
    @name = name
  end
end

# This is the class that invokes the method on the producer to create the required message
# This class would be written by the producer team, but we should come up with some recommended implementations
# And a nice DSL to allow the producer team to configure it without having to know about the HTTP stuff.
class MessageInvoker
  def initialize
    @alligator = nil
  end

  def invoke message_descriptor
    set_up_provider_states(message_descriptor.provider_states)
    get_message_invocation(message_descriptor.description).call
  end

  private

  def set_up_provider_states provider_states
    provider_states.each do | provider_state |
      case provider_state.name
      when nil then nil
      when "" then nil
      when "an alligator named Mary exists" then set_up_alligator_with_name("Mary")
      when "an alligator named John exists" then set_up_alligator_with_name("John")
      else
        raise "Unknown provider state '#{provider_state.name}'"
      end
    end
  end

  def get_message_invocation message_description
    case message_description
    when "a hello message" then hello_message
    when "a goodbye message" then goodbye_message
    else
      raise StandardError.new("Unknown method on Producer for message with description '#{message_description}'")
    end
  end

  def hello_message
    # must declare arguments in local scope, because lambdas don't have access to
    # instance variables
    argument = @alligator
    lambda { HelloProducerService.new.hello_message(argument)  }
  end

  def goodbye_message
    argument = @alligator
    lambda { GoodbyeProducerService.new.goodbye_message(argument)  }
  end

  def set_up_alligator_with_name name
    @alligator = Alligator.new(name)
  end
end

run HttpRequestHandler.new(MessageInvoker.new)
