class Ragoon::Services::Schedule < Ragoon::Services
  def schedule_get_events(options = {})
    action_name = 'ScheduleGetEvents'

    options = default_options(action_name).merge(options)

    body_node = Ragoon::XML.create_node(action_name)
    parameter_node = Ragoon::XML.create_node(
      'parameters',
      start: options[:start].strftime('%FT%T'),
      end:   options[:end].strftime('%FT%T')
    )
    body_node.add_child(parameter_node)

    client.request(action_name, body_node)
    client
  end

  def default_options(action_name)
    case action_name
    when 'ScheduleGetEvents'
      today = Date.today
      {
        start: Time.local(today.year, today.month, today.day,  8, 0),
        end:   Time.local(today.year, today.month, today.day, 23, 0),
      }
    else
      {}
    end
  end
end
