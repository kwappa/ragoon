class Ragoon::Client
  attr_reader :endpoint, :response

  def initialize(endpoint, options)
    @endpoint = endpoint
    @options = options
  end

  def request(action_name, body_node)
    reset
    @action_name = action_name
    @body_node = body_node
    @response = RestClient.post(endpoint, Ragoon::XML.render(action_name, body_node, @options))
  ensure
    raise_error unless result_set.xpath('//soap:Fault').empty?
  end

  def result_set
    @result_set ||= Nokogiri::XML.parse(response.body)
  end

  def reset
    @result_set = nil
  end

  private

  def raise_error
    raise Ragoon::Error.new(
      result_set.xpath('//soap:Reason').text.strip,
      result_set.xpath('//soap:Detail/*').map { |c| [c.name, c.text.strip] }.to_h
    )
  end
end
