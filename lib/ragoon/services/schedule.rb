class Ragoon::Services::Schedule < Ragoon::Services
  def schedule_get_events(options = {})
    action_name = 'ScheduleGetEvents'

    options = default_options(action_name).merge(options)

    body_node = Ragoon::XML.create_node(action_name)
    parameter_node = Ragoon::XML.create_node(
      'parameters',
      start:           options[:start].strftime('%FT%T'),
      end:             options[:end].strftime('%FT%T'),
      start_for_daily: options[:start].strftime('%F'),
      end_for_daily:   options[:end].strftime('%F'),
    )
    body_node.add_child(parameter_node)

    client.request(action_name, body_node)
    events = client.result_set.xpath('//schedule_event').
             find_all { |ev| ev[:event_type] != 'banner' }.map do |event|
      public_event = event[:public_type] == 'public'
      {
        title:    public_event ? event[:detail] : '予定あり',
        period:   start_and_end(event),
        plan:     public_event ? event[:plan] : '',
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
      case event[:event_type]
      when 'normal'
        period = event.children.xpath('ev:datetime', ev: "http://schemas.cybozu.co.jp/schedule/2008").first
        return '' if period.nil?
        start_time = parse_event_time(period[:start])
        end_time = event[:start_only] == 'true' ? '' : parse_event_time(period[:end])
      when 'repeat'
        repeat_info = event.xpath('ev:repeat_info', ev: 'http://schemas.cybozu.co.jp/schedule/2008').first
        return '' if repeat_info.nil?
        period = repeat_info.xpath('ev:condition', ev: 'http://schemas.cybozu.co.jp/schedule/2008').first
        return '' if period.nil?
        start_time = parse_event_time(period[:start_time])
        end_time = event[:start_only] == 'true' ? '' : parse_event_time(period[:end_time])
      else
        return ''
      end

      "#{start_time}〜#{end_time}"
    end
  end


  def parse_event_time(time)
    Time.parse(time).localtime.strftime('%R')
  end

  def default_options(action_name)
    case action_name
    when 'ScheduleGetEvents'
      Ragoon::Services.start_and_end
    else
      {}
    end
  end
end
