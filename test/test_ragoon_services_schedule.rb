require 'test_helper'

class TestRagoonServicesSchedule < Test::Unit::TestCase
  extend ::TestHelper

  cassette_scope 'schedule'

  event_url_base = 'http://onlinedemo2.cybozu.info/scripts/garoon/grn.exe/schedule/view?event='

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
            :start_at => nil,
            :end_at => nil,
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => true,
          }, act)

        assert_include_event({
            :title => "2days Event",
            :plan => nil,
            :start_at => nil,
            :end_at => nil,
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

        # FIXME Date of repeat type event isn't correct.
        today = Date.today.strftime('%F')
        assert_include_event({
            :title => "Repeat everyday",
            :plan => "【会議】",
            :start_at => "#{today} 11:00:00 +0900",
            :end_at => "#{today} 12:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat week start_only",
            :plan => nil,
            :start_at => "#{today} 21:30:00 +0900",
            :end_at => nil,
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat lastweek",
            :plan => nil,
            :start_at => "#{today} 03:45:00 +0900",
            :end_at => "#{today} 04:15:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => ["第一会議室"],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat month",
            :plan => nil,
            :start_at => "#{today} 16:30:00 +0900",
            :end_at => "#{today} 17:00:00 +0900",
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
            :start_at => nil,
            :end_at => nil,
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => true,
          }, act)

        assert_include_event({
            :title => "2days Event",
            :plan => nil,
            :start_at => nil,
            :end_at => nil,
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :private => false,
            :allday => true,
          }, act)

        # FIXME Date of repeat type event isn't correct.
        today = Date.today.strftime('%F')
        assert_include_event({
            :title => "Repeat everyday",
            :plan => "【会議】",
            :private => false,
            :start_at => "#{today} 11:00:00 +0900",
            :end_at => "#{today} 12:30:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => [],
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat lastweek",
            :plan => nil,
            :start_at => "#{today} 03:45:00 +0900",
            :end_at => "#{today} 04:15:00 +0900",
            :users => [{:id => 6, :name => "佐藤 昇"}],
            :facilities => ["第一会議室"],
            :private => false,
            :allday => false,
          }, act)

        assert_include_event({
            :title => "Repeat month",
            :plan => nil,
            :start_at => "#{today} 16:30:00 +0900",
            :end_at => "#{today} 17:00:00 +0900",
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
          start_at: nil,
          end_at: nil,
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

end

