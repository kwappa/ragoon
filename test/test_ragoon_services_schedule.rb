require 'test_helper'

class TestRagoonServicesSchedule < Test::Unit::TestCase
  extend ::TestHelper

  cassette_scope 'schedule'

  event_url_base = 'http://onlinedemo2.cybozu.info/scripts/garoon/grn.exe/schedule/view?event='

  dummy_opts = {
    endpoint: "http://example.com/path/to",
    username: "username",
    password: "password"
  }

  sub_test_case '.event_url(id)' do
    test 'endpoint without query' do
      opts = {
        garoon_endpoint: "http://example.com/path/to",
        garoon_username: "username",
        garoon_password: "password"
      }
      Ragoon.class_variable_set :@@secret_options, opts
      service = Ragoon::Services::Schedule.new
      assert_equal("http://example.com/path/to/schedule/view?event=11",
                   service.event_url(11))
      assert_equal("http://example.com/path/to/schedule/view?event=22",
                   service.event_url(22))
    end

    test 'endpoint with query' do
      opts = {
        garoon_endpoint: "http://example.com/path/to?param=value&key=value",
        garoon_username: "username",
        garoon_password: "password"
      }
      Ragoon.class_variable_set :@@secret_options, opts
      service = Ragoon::Services::Schedule.new
      assert_equal("http://example.com/path/to/schedule/view?event=11",
                   service.event_url(11))
      assert_equal("http://example.com/path/to/schedule/view?event=22",
                   service.event_url(22))
    end

    teardown do
      Ragoon.class_variable_set :@@secret_options, {}
    end
  end

  sub_test_case 'with http request' do
    setup do
      @service = Ragoon::Services::Schedule.new(TEST_ENDPOINT_OPTS)
    end

    sub_test_case '.schedule_get_events()' do

      def self.startup
        VCR.use_cassette("add_fixture_events") do
          @new_events = add_fixture_events(
            'test/fixtures/schedule_events.xml', TEST_ENDPOINT_OPTS)
        end
      end

      def self.shutdown
        return if @new_events.nil?

        VCR.use_cassette("delete_events") do
          ids_by_type = @new_events.inject({}) {|r, e|
            r[e[:event_type]] ||= []
            r[e[:event_type]] << e[:id]
            r
          }
          delete_normal_events(ids_by_type['normal'], TEST_ENDPOINT_OPTS)
          delete_repeat_events(ids_by_type['repeat'], TEST_ENDPOINT_OPTS)
        end
      end

      test_with_cassette 'get events' do
        act = @service.schedule_get_events(
          start: Time.new(2016, 9, 26, 10, 0, 0),
          end: Time.new(2016, 9, 29, 10, 0, 0)
        )

        assert_all_urls_of_events(event_url_base, act)

        assert_include_event({
            :title => "Allday Event",
            :plan => nil,
            :start_at => '2016-09-28 00:00:00 +0900',
            :end_at => '2016-09-28 23:59:59 +0900',
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => true,
          }, act)

        assert_include_event({
            :title => "2days Event",
            :plan => nil,
            :start_at => '2016-09-27 00:00:00 +0900',
            :end_at => '2016-09-28 23:59:59 +0900',
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => true,
          }, act)

        assert_include_event({
            :title => "Start only Event",
            :plan => nil,
            :start_at => "2016-09-27 22:00:00 +0900",
            :end_at => nil,
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Normal Event",
            :plan => nil,
            :start_at => "2016-09-27 12:00:00 +0900",
            :end_at => "2016-09-27 14:15:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Normal 2days Event",
            :plan => nil,
            :start_at => "2016-09-26 20:00:00 +0900",
            :end_at => "2016-09-27 10:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat everyday",
            :plan => "【会議】",
            :start_at => "2016-09-26 11:00:00 +0900",
            :end_at => "2016-09-26 12:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat everyday",
            :plan => "【会議】",
            :start_at => "2016-09-27 11:00:00 +0900",
            :end_at => "2016-09-27 12:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat everyday",
            :plan => "【会議】",
            :start_at => "2016-09-28 11:00:00 +0900",
            :end_at => "2016-09-28 12:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat week start_only",
            :plan => nil,
            :start_at => "2016-09-27 21:30:00 +0900",
            :end_at => nil,
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat lastweek",
            :plan => nil,
            :start_at => "2016-09-28 03:45:00 +0900",
            :end_at => "2016-09-28 04:15:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => ["第一会議室"],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat month",
            :plan => nil,
            :start_at => "2016-09-28 16:30:00 +0900",
            :end_at => "2016-09-28 17:00:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"} ],
            :facilities => ["第一会議室"],
            :private => false,
            :allday => false,
          }, act)
      end

      test_with_cassette 'get events in a day' do
        act = @service.schedule_get_events(
          Ragoon::Services.start_and_end(Date.new(2016, 9, 28))
        )

        assert_all_urls_of_events(event_url_base, act)

        assert_include_event({
            :title => "Allday Event",
            :plan => nil,
            :start_at => '2016-09-28 00:00:00 +0900',
            :end_at => '2016-09-28 23:59:59 +0900',
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => true,
          }, act)

        assert_include_event({
            :title => "2days Event",
            :plan => nil,
            :start_at => '2016-09-27 00:00:00 +0900',
            :end_at => '2016-09-28 23:59:59 +0900',
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => true,
          }, act)

        assert_include_event({
            :title => "Repeat everyday",
            :plan => "【会議】",
            :private => false,
            :start_at => "2016-09-28 11:00:00 +0900",
            :end_at => "2016-09-28 12:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat lastweek",
            :plan => nil,
            :start_at => "2016-09-28 03:45:00 +0900",
            :end_at => "2016-09-28 04:15:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => ["第一会議室"],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat month",
            :plan => nil,
            :start_at => "2016-09-28 16:30:00 +0900",
            :end_at => "2016-09-28 17:00:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => ["第一会議室"],
            :private => false,
            :allday => false,
          }, act)
      end

      test_with_cassette 'get event within a few hours' do
        pend "can't get any events"

        act = @service.schedule_get_events(
          start: Time.new(2016, 9, 26, 11, 0, 0),
          end: Time.new(2016, 9, 26, 12, 30, 0)
        )

        assert_all_urls_of_events(event_url_base, act)

        assert_include_event({
            :title => "Repeat everyday",
            :plan => "【会議】",
            :private => false,
            :start_at => "2016-09-26 11:00:00 +0900",
            :end_at => "2016-09-26 12:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :allday => false,
          }, act)

      end
    end

    sub_test_case '.schedule_add_event()' do

      test_with_cassette 'add nomal event' do
        act = @service.schedule_add_event(
          title: 'Normal Event',
          description: '概要説明',
          plan: '社内MTG',
          start_at: Time.new(2016, 1, 15, 13, 0),
          end_at: Time.new(2016, 1, 15, 13, 30),
          users: [ 1 ],
          private: false,
          allday: false
        )

        assert_all_urls_of_events(event_url_base, act)
        assert_include_event({
          title: 'Normal Event',
          plan: '社内MTG',
          start_at: '2016-01-15 13:00:00 +0900',
          end_at: '2016-01-15 13:30:00 +0900',
          allday: false,
          users: [
            {id: 1, name: 'Administrator'}
          ],
          facilities: [],
          private: false,
        }, act)
      end

      test_with_cassette 'add start only event' do
        act = @service.schedule_add_event(
          title: 'Start only Event',
          description: '概要説明',
          start_at: Time.new(2016, 1, 15, 21, 0),
          plan: '社内MTG',
          users: [1],
          private: false,
          allday: false
        )

        assert_all_urls_of_events(event_url_base, act)
        assert_include_event({
          title: 'Start only Event',
          plan: '社内MTG',
          start_at: '2016-01-15 21:00:00 +0900',
          end_at: nil,
          allday: false,
          users: [
            {id: 1, name: 'Administrator'}
          ],
          facilities: [],
          private: false,
        }, act)
      end

      test_with_cassette 'add allday event' do
        act = @service.schedule_add_event(
          title: 'Allday Event',
          description: '概要説明',
          start_at: Time.new(2016, 1, 15, 1, 0),
          end_at: Time.new(2016, 1, 15, 1, 30),
          plan: '社内MTG',
          users: [ 1 ],
          private: false,
          allday: true
        )

        assert_all_urls_of_events(event_url_base, act)
        assert_include_event({
          title: 'Allday Event',
          plan: '社内MTG',
          start_at: '2016-01-15 00:00:00 +0900',
          end_at: '2016-01-15 23:59:59 +0900',
          allday: true,
          users: [
            {id: 1, name: 'Administrator'}
          ],
          facilities: [],
          private: false
        }, act)
      end
    end

  end

  private

  def assert_include_event(expect_event_without_id_url, actual_events, message = nil)
    actual_events = [actual_events] unless actual_events.instance_of?(Array)

    full_message = build_message(
      message, "<?> expected to include\n<?>",
      actual_events, expect_event_without_id_url)

    assert_block(full_message) do
      actual_events.any? {|e|
        e == expect_event_without_id_url.merge(id: e[:id], url: e[:url])
      }
    end
  end

  def assert_all_urls_of_events(expect_url_base, actual_events, message = nil)
    actual_events = [actual_events] unless actual_events.instance_of?(Array)

    actual_events.each do |e|
      full_message = build_message(message, "url of <?>", e)
      assert_equal(expect_url_base + e[:id], e[:url], full_message)
    end
  end

  class << self

    def add_fixture_events(fixture_xml_file_path, options)
      xml_file = File.read(fixture_xml_file_path)
      action_name = 'ScheduleAddEvents'
      body_node = Ragoon::XML.create_node(action_name) <<
        (Ragoon::XML.create_node('parameters') << xml_file)

      client = Ragoon::Services::Schedule.new(options).client
      client.request(action_name, body_node)
      fault = client.result_set.xpath('//soap:Fault/soap:Detail').first
      unless fault.nil?
        raise fault.text
      end

      # new_events
      client.result_set.xpath('//schedule_event')
    end

    def delete_normal_events(id_list, options)
      action_name = 'ScheduleRemoveEvents'
      body_node = Ragoon::XML.create_node(action_name) <<
        id_list.inject(Ragoon::XML.create_node('parameters')) {|parent, id|
          node = Ragoon::XML.create_node('event_id')
          node.content = id
          parent << node
        }

      client = Ragoon::Services::Schedule.new(options).client
      client.request(action_name, body_node)
      fault = client.result_set.xpath('//soap:Fault/soap:Detail').first
      unless fault.nil?
        raise fault.text
      end
    end

    def delete_repeat_events(id_list, options)
      action_name = 'ScheduleRemoveEventsFromRepeatEvent'
      body_node = Ragoon::XML.create_node(action_name) <<
        id_list.inject(Ragoon::XML.create_node('parameters')) {|parent, id|
          parent << Ragoon::XML.create_node(
            'operation',
            event_id: id,
            type: 'all'
          )
        }

      client = Ragoon::Services::Schedule.new(options).client
      client.request(action_name, body_node)
      fault = client.result_set.xpath('//soap:Fault/soap:Detail').first
      unless fault.nil?
        raise fault.text
      end
    end
  end


  sub_test_case '.expand_dates()' do
    service = Ragoon::Services::Schedule.new(dummy_opts)

    expand_dates = lambda do |start_date, end_date, cond, exclusive_dates|
      service.send(:expand_dates, start_date, end_date, cond, exclusive_dates)
    end

    def dates(year, month, *ranges)
      ranges.map {|r|
        r.respond_to?(:to_a) ? r.to_a : r
      }.flatten.map {|d|
        Date.new(year, month, d)
      }
    end

    test 'type == "day"' do
      start_date = Date.new(2016, 10, 1)
      end_date = Date.new(2016, 10, 31)
      exclusive_dates = dates(2016, 10, [3, 10])

      cond = {type: 'day'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 10, 1..2, 4..9, 11..31), act)
    end

    test 'type == "week"' do
      start_date = Date.new(2016, 10, 1)
      end_date = Date.new(2016, 10, 31)
      exclusive_dates = dates(2016, 10, [9, 15])

      cond = {type: 'week', week: '0'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 10, [2, 16, 23, 30]), act)

      cond = {type: 'week', week: '6'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 10, [1, 8, 22, 29]), act)
    end

    test 'type == "weekday"' do
      start_date = Date.new(2016, 10, 1)
      end_date = Date.new(2016, 10, 31)
      exclusive_dates = dates(2016, 10, [9, 12])

      cond = {type: 'weekday'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 10, 3..7, 10..11, 13..14, 17..21, 24..28, 31), act)
    end

    test 'type == "1stweek"' do
      start_date = Date.new(2016, 9, 1)
      end_date = Date.new(2016, 11, 30)
      exclusive_dates = []

      cond = {type: '1stweek', week: '2'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 6) + dates(2016, 10, 4) + dates(2016, 11, 1), act)
    end

    test 'type == "2ndweek"' do
      start_date = Date.new(2016, 9, 1)
      end_date = Date.new(2016, 11, 30)
      exclusive_dates = []

      cond = {type: '2ndweek', week: '2'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 13) + dates(2016, 10, 11) + dates(2016, 11, 8), act)
    end

    test 'type == "3rdweek"' do
      start_date = Date.new(2016, 9, 1)
      end_date = Date.new(2016, 11, 30)
      exclusive_dates = []

      cond = {type: '3rdweek', week: '2'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 20) + dates(2016, 10, 18) + dates(2016, 11, 15), act)
    end

    test 'type == "4thweek"' do
      start_date = Date.new(2016, 9, 1)
      end_date = Date.new(2016, 11, 30)
      exclusive_dates = []

      cond = {type: '4thweek', week: '2'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 27) + dates(2016, 10, 25) + dates(2016, 11, 22), act)
    end

    test 'type == "lastweek"' do
      start_date = Date.new(2016, 9, 1)
      end_date = Date.new(2016, 11, 30)
      exclusive_dates = []

      cond = {type: 'lastweek', week: '0'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 25) + dates(2016, 10, 30) + dates(2016, 11, 27), act)
      cond = {type: 'lastweek', week: '2'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 27) + dates(2016, 10, 25) + dates(2016, 11, 29), act)
      cond = {type: 'lastweek', week: '6'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 24) + dates(2016, 10, 29) + dates(2016, 11, 26), act)
    end

    test 'type == "month"' do
      start_date = Date.new(2016, 9, 1)
      end_date = Date.new(2016, 11, 30)
      exclusive_dates = []

      cond = {type: 'month', day: '2'}
      act = expand_dates.call(start_date, end_date, cond, exclusive_dates)
      assert_equal(dates(2016, 9, 2) + dates(2016, 10, 2) + dates(2016, 11, 2), act)
    end
  end

  sub_test_case '.nth_weekday_of_month()' do
    service = Ragoon::Services::Schedule.new(dummy_opts)

    nth_weekday_of_month = lambda do |year, month, day|
      service.send(:nth_weekday_of_month, Date.new(year, month,  day))
    end

    test '1st day of the month is Sunday' do
      assert_equal(0, Date.new(2016, 5, 1).wday)
      assert_equal(1, nth_weekday_of_month.call(2016, 5,  1))
      assert_equal(1, nth_weekday_of_month.call(2016, 5,  7))
      assert_equal(2, nth_weekday_of_month.call(2016, 5,  8))
      assert_equal(2, nth_weekday_of_month.call(2016, 5, 14))
      assert_equal(3, nth_weekday_of_month.call(2016, 5, 15))
      assert_equal(3, nth_weekday_of_month.call(2016, 5, 21))
      assert_equal(4, nth_weekday_of_month.call(2016, 5, 22))
      assert_equal(4, nth_weekday_of_month.call(2016, 5, 28))
      assert_equal(5, nth_weekday_of_month.call(2016, 5, 29))
      assert_equal(5, nth_weekday_of_month.call(2016, 5, 30))
    end

    test '1st day of the month is Saturday' do
      assert_equal(6, Date.new(2016, 10, 1).wday)
      assert_equal(1, nth_weekday_of_month.call(2016, 10,  1))
      assert_equal(1, nth_weekday_of_month.call(2016, 10,  7))
      assert_equal(2, nth_weekday_of_month.call(2016, 10,  8))
      assert_equal(2, nth_weekday_of_month.call(2016, 10, 14))
      assert_equal(3, nth_weekday_of_month.call(2016, 10, 15))
      assert_equal(3, nth_weekday_of_month.call(2016, 10, 21))
      assert_equal(4, nth_weekday_of_month.call(2016, 10, 22))
      assert_equal(4, nth_weekday_of_month.call(2016, 10, 28))
      assert_equal(5, nth_weekday_of_month.call(2016, 10, 29))
      assert_equal(5, nth_weekday_of_month.call(2016, 10, 31))
    end
  end

end

