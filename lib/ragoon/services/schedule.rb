class Ragoon::Services::Schedule < Ragoon::Services
  XML_NS = 'http://schemas.cybozu.co.jp/schedule/2008'

  def schedule_get_events(options = {})
    action_name = 'ScheduleGetEvents'

    options = default_options(action_name).merge(options)

    body_node = Ragoon::XML.create_node(action_name)
    parameter_node = Ragoon::XML.create_node(
      'parameters',
      start:           to_datetime_str(options[:start]),
      end:             to_datetime_str(options[:end]),
      start_for_daily: to_date_str(options[:start]),
      end_for_daily:   to_date_str(options[:end]),
    )
    body_node.add_child(parameter_node)

    client.request(action_name, body_node)

    events_by_type = client.result_set.xpath('//schedule_event')
      .group_by {|ev| ev[:event_type] }

    # events_by_type['banner'] does not include results
    [
      (events_by_type['normal'] || []).map {|event|
        parse_event(event)
      },
      (events_by_type['repeat'] || []).map {|event|
        expand_repeat_event_periods(event, options[:start], options[:end]).map {|period|
          parse_event(event, period)
        }
      }
    ].flatten
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
        public_type: (options[:private] ? 'private' : 'public')
      }
    )
    parameter_node.add_child(schedule_event_node)

    members_node = Ragoon::XML.create_node('members', xmlns: XML_NS)
    schedule_event_node.add_child(members_node)
    if options[:users]
      options[:users].each do |user|
        member_node = Ragoon::XML.create_node('member')
        user_node = Ragoon::XML.create_node('user', id: user.to_i)
        member_node.add_child(user_node)
        members_node.add_child(member_node)
      end
    end

    when_node = Ragoon::XML.create_node('when', xmlns: XML_NS)
    date_node =
      if options[:allday]
        Ragoon::XML.create_node(
          'date',
          start: to_date_str(options[:start_at]),
          end:   to_date_str(options[:end_at])
        )
      else
        Ragoon::XML.create_node(
          'datetime',
          start: to_datetime_str(options[:start_at]),
          end:   to_datetime_str(options[:end_at])
        )
      end
    when_node.add_child(date_node)
    schedule_event_node.add_child(when_node)

    client.request(action_name, body_node)

    events = client.result_set.xpath('//schedule_event').
             find_all { |ev| ev[:event_type] != 'banner' }.map { |event|
      parse_event(event)
    }.first
  end

  def parse_event(event, period = nil)
    period = start_and_end(event) if period.nil?

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
    "#{base_endpoint}/schedule/view?event=#{id}"
  end

  def facility_names(event)
    event.xpath('ev:members', ev: XML_NS).
      children.map { |c| c.xpath('ev:facility', ev: XML_NS).first }.
      compact.map { |n| n[:name] }
  end

  def users_info(event)
    event.xpath('ev:members', ev: XML_NS).
      children.map { |c| c.xpath('ev:user', ev: XML_NS).first }.
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
    timezone = event[:timezone]
    end_timezone = event[:end_timezone] || event[:timezone]

    unless event[:allday] == 'true'
      period = event.xpath('ev:when/ev:datetime', ev: XML_NS).first
      unless period.nil?
        start_at = parse_event_time(period[:start], timezone)
        end_at = parse_event_time(period[:end], end_timezone)
      end

    else
      period = event.xpath('ev:when/ev:date', ev: XML_NS).first
      unless period.nil?
        start_at = parse_event_time(period[:start], timezone)
        end_at = parse_event_time(period[:end] + " 23:59:59", end_timezone)
      end
    end

    {
      start_at: start_at,
      end_at:   end_at,
    }
  end

  def parse_event_time(time, timezone = ENV['TZ'], now = Time.now)
    return nil if time.nil?

    begin
      old_timezone = ENV['TZ']
      ENV['TZ'] = timezone
      Time.parse(time, now).localtime.to_s
    ensure
      ENV['TZ'] = old_timezone
    end
  end

  def default_options(action_name)
    case action_name
    when 'ScheduleGetEvents'
      Ragoon::Services.start_and_end
    else
      {}
    end
  end

  private

  def expand_repeat_event_periods(event, start_at, end_at)
    timezone = event[:timezone]
    end_timezone = event[:end_timezone] || event[:timezone]

    periods = []

    event.xpath('ev:repeat_info/ev:condition', ev: XML_NS).each do |cond|
      exclusive_dates = event.xpath('ev:repeat_info/ev:exclusive_datetimes/ev:exclusive_datetime',
                                    ev: XML_NS).map do |exclusive_date|
        Date.parse(exclusive_date[:start])
      end

      dates = expand_dates(start_at.to_date, end_at.to_date, cond, exclusive_dates)

      periods = dates.map do |date|
        {
          start_at: parse_event_time(cond[:start_time], timezone, date.to_time),
          end_at: parse_event_time(cond[:end_time], end_timezone, date.to_time)
        }
      end
    end

    periods
  end

  def expand_dates(start_date, end_date, cond, exclusive_dates)
    (start_date..end_date).select {|date|
      next false if exclusive_dates.include?(date)

      case cond[:type]
      when 'day' # everyday
        next true

      when 'week' # everyweek
        next date.wday == cond[:week].to_i

      when 'weekday'
        next (1..5).include?(date.wday)

      when '1stweek'
        next nth_weekday_of_month(date) == 1 && date.wday == cond[:week].to_i

      when '2ndweek'
        next nth_weekday_of_month(date) == 2 && date.wday == cond[:week].to_i

      when '3rdweek'
        next nth_weekday_of_month(date) == 3 && date.wday == cond[:week].to_i

      when '4thweek'
        next nth_weekday_of_month(date) == 4 && date.wday == cond[:week].to_i

      when 'lastweek'
        next date.month != date.next_day(7).month &&
          date.wday == cond[:week].to_i

      when 'month'
        next date.day == cond[:day].to_i

      end
    }
  end

  def nth_weekday_of_month(date)
    (date.day + 6) / 7
  end
end
