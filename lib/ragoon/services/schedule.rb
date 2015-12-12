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
      period = start_and_end(event)
      {
        url:         event_url(event[:id]),
        title:      event[:detail],
        start_at:   period[:start_at],
        end_at:     period[:end_at],
        plan:       event[:plan],
        facilities: facility_names(event),
        private:    !(event[:public_type] == 'public'),
        allday:     event[:allday] == 'true',
      }
    end
  end

  def event_url(id)
    "#{Ragoon::garoon_endpoint.gsub(/\?.*\Z/, '')}/schedule/view?event=#{id}"
  end

  def facility_names(event)
    event.xpath('ev:members', ev: "http://schemas.cybozu.co.jp/schedule/2008").
      children.map { |c| c.xpath('ev:facility', ev: "http://schemas.cybozu.co.jp/schedule/2008").first }.
      compact.map { |n| n[:name] }
  end

  def start_and_end(event)
    start_at = nil
    end_at   = nil

    unless event[:allday] == 'true'
      case event[:event_type]
      when 'normal'
        period = event.children.xpath('ev:datetime', ev: "http://schemas.cybozu.co.jp/schedule/2008").first
        unless period.nil?
          start_at = parse_event_time(period[:start])
          unless event[:start_only] == 'true'
            end_at = parse_event_time(period[:end])
          end
        end
      when 'repeat'
        repeat_info = event.xpath('ev:repeat_info', ev: 'http://schemas.cybozu.co.jp/schedule/2008').first
        unless repeat_info.nil?
          period = repeat_info.xpath('ev:condition', ev: 'http://schemas.cybozu.co.jp/schedule/2008').first
          unless period.nil?
            start_at = parse_event_time(period[:start_time])
            unless event[:start_only] == 'true'
              end_at = parse_event_time(period[:end_time])
            end
          end
        end
      end
    end

    {
      start_at: start_at,
      end_at:   end_at,
    }
  end

  def parse_event_time(time)
    Time.parse(time).localtime.to_s
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
