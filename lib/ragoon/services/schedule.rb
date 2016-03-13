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
      parse_event(event)
    end
  end

  def schedule_add_event(options = {})
    action_name = 'ScheduleAddEvents'

    options = default_options(action_name).merge(options)

    body_node = Ragoon::XML.create_node(action_name)
    parameter_node = Ragoon::XML.create_node('parameters')
    body_node.add_child(parameter_node)

    schedule_event_node = Ragoon::XML.create_node(
      'schedule_event',
      {
        xmlns:       '',
        id:          'dummy',
        version:     'dummy',
        event_type:  'normal',
        plan:        options[:plan],
        detail:      options[:title],
        description: options[:description],
        allday:      options[:allday],
        public_type: (options[:private] ? 'private' : 'public')
      }
    )
    parameter_node.add_child(schedule_event_node)

    members_node = Ragoon::XML.create_node(
      'members',
      xmlns: 'http://schemas.cybozu.co.jp/schedule/2008'
    )
    schedule_event_node.add_child(members_node)
    if options[:users]
      options[:users].each do |user|
        member_node = Ragoon::XML.create_node('member')
        user_node = Ragoon::XML.create_node('user', id: user.to_i)
        member_node.add_child(user_node)
        members_node.add_child(member_node)
      end
    end

    when_node = Ragoon::XML.create_node(
      'when',
      xmlns: 'http://schemas.cybozu.co.jp/schedule/2008'
    )
    date_node = Ragoon::XML.create_node(
      'datetime',
      start: options[:start_at].utc.strftime('%FT%T'),
      end:   options[:end_at].utc.strftime('%FT%T')
    )
    when_node.add_child(date_node)
    schedule_event_node.add_child(when_node)

    client.request(action_name, body_node)

    events = client.result_set.xpath('//schedule_event').
             find_all { |ev| ev[:event_type] != 'banner' }.map { |event|
      parse_event(event)
    }.first
  end

  def parse_event(event)
    period = start_and_end(event)
    {
      id:         event[:id],
      url:        event_url(event[:id]),
      title:      event[:detail],
      start_at:   period[:start_at],
      end_at:     period[:end_at],
      plan:       event[:plan],
      facilities: facility_names(event),
      users:      users_info(event),
      private:    !(event[:public_type] == 'public'),
      allday:     event[:allday] == 'true',
    }
  end

  def event_url(id)
    "#{Ragoon::garoon_endpoint.gsub(/\?.*\Z/, '')}/schedule/view?event=#{id}"
  end

  def facility_names(event)
    event.xpath('ev:members', ev: "http://schemas.cybozu.co.jp/schedule/2008").
      children.map { |c| c.xpath('ev:facility', ev: "http://schemas.cybozu.co.jp/schedule/2008").first }.
      compact.map { |n| n[:name] }
  end

  def users_info(event)
    event.xpath('ev:members', ev: "http://schemas.cybozu.co.jp/schedule/2008").
      children.map { |c| c.xpath('ev:user', ev: "http://schemas.cybozu.co.jp/schedule/2008").first }.
      compact.map do |n|
        {
          id: n[:id].to_i,
          name: n[:name].to_s,
        }
      end
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
