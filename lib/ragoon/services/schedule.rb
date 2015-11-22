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

    events = client.result_set.xpath('//schedule_event').find_all { |ev| ev[:event_type] == 'normal' }.map do |event|
      public_event = event[:public_type] == 'public'
      {
        title:    public_event ? event[:detail] : '予定あり',
        period:   start_and_end(event),
        facility: public_event ? facility_names(event) : [],
      }
    end
  end

  def facility_names(event)
    event.xpath('ev:members', ev: "http://schemas.cybozu.co.jp/schedule/2008").
      children.map { |c| c.xpath('ev:facility', ev: "http://schemas.cybozu.co.jp/schedule/2008").first }.
      compact.map { |n| n[:name] }
  end

  def start_and_end(event)
    if event[:allday] == 'true'
      '終日'
    else
      period = event.children.xpath('ev:datetime', ev: "http://schemas.cybozu.co.jp/schedule/2008").first

      return 'error' if period.nil?

      start_time = Time.parse(period[:start]).localtime.strftime('%R')
      end_time = event[:start_only] == 'true' ? '' : Time.parse(period[:end]).localtime.strftime('%R')
      "#{start_time}〜#{end_time}"
    end
  end

  def default_options(action_name)
    case action_name
    when 'ScheduleGetEvents'
      today = Date.today
      {
        start: Time.local(today.year, today.month, today.day,     0).utc,
        end:   Time.local(today.year, today.month, today.day + 1, 0).utc,
      }
    else
      {}
    end
  end
end
