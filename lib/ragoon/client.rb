class Ragoon::Client
  attr_reader :endpoint, :response

  def initialize(endpoint, options)
    @endpoint = endpoint
    @options = options
  end

  def request(action_name, body_node)
    @action_name = action_name
    @body_node = body_node
    @response = RestClient.post(endpoint, Ragoon::XML.render(action_name, body_node, @options))
  end

  def result_set
    @result_set ||= Nokogiri::XML.parse(response.body)
  end

  def reset
    @result_set = nil
  end
end
