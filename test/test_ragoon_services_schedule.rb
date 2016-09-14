require 'test_helper'

class TestRagoonServicesSchedule < Test::Unit::TestCase

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

end

