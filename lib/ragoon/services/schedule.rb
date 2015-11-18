class Ragoon::Services::Schedule < Ragoon::Services
  def request(action_name, body_node)
    @request.action_name = action_name
    @request.body_node   = body_node
    response = RestClient.post(endpoint, @request.to_xml)
    @response = Nokogiri::XML.parse(response.body)
  end

  def schedule_get_events(options = {})
    options = default_options.merge(options)

    action_name = 'ScheduleGetEvents'

    body_node = @request.create_node(action_name)
    parameter_node = @request.create_node(
      'parameters',
      start: options[:start].strftime('%FT%T'),
      end:   options[:end].strftime('%FT%T')
    )
    body_node.add_child(parameter_node)

    request(action_name, body_node)
  end

  def default_options
    today = Date.today
    {
      start: Time.local(today.year, today.month, today.day,  8, 0),
      end:   Time.local(today.year, today.month, today.day, 23, 0),
    }
  end
end
