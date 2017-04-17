require 'test_helper'

class TestRagoonServices < Test::Unit::TestCase
  sub_test_case '.start_and_end' do
    test 'without argument' do
      result = Ragoon::Services.start_and_end
      current_date = Date.today
      assert_equal(result[:start], current_date.to_time.utc)
      assert_equal(result[:end], ((current_date + 1).to_time - 1).utc)
    end

    test 'with argument as tomorrow' do
      current_date = Date.today + 1
      result = Ragoon::Services.start_and_end(current_date)
      assert_equal(result[:start], current_date.to_time.utc)
      assert_equal(result[:end], ((current_date + 1).to_time - 1).utc)
    end

    test 'with argument as yesterday' do
      current_date = Date.today - 1
      result = Ragoon::Services.start_and_end(current_date)
      assert_equal(result[:start], current_date.to_time.utc)
      assert_equal(result[:end], ((current_date + 1).to_time - 1).utc)
    end
  end

  sub_test_case '.endpoint' do
    test 'by ENV["garoon_endpoint"]' do
      ENV['GAROON_ENDPOINT'] = "http://example.com/by_env"
      ENV['GAROON_USERNAME'] = "username"
      ENV['GAROON_PASSWORD'] = "password"
      ENV['GAROON_VERSION']  = '3'
      service = Ragoon::Services::Schedule.new
      assert_equal("http://example.com/by_env/cbpapi/schedule/api?",
                   service.endpoint)
    end

    test 'by ENV["garoon_endpoint"] with Garoon version 4' do
      ENV['GAROON_ENDPOINT'] = "http://example.com/by_env"
      ENV['GAROON_USERNAME'] = "username"
      ENV['GAROON_PASSWORD'] = "password"
      ENV['GAROON_VERSION']  = '4'
      service = Ragoon::Services::Schedule.new
      assert_equal("http://example.com/by_env/cbpapi/schedule/api.csp?",
                   service.endpoint)
    end

    test 'by secret_options' do
      opts = {
        garoon_endpoint: "http://example.com/by_secret",
        garoon_username: "username",
        garoon_password: "password",
        garoon_version:  3
      }
      Ragoon.class_variable_set :@@secret_options, opts
      service = Ragoon::Services::Schedule.new
      assert_equal("http://example.com/by_secret/cbpapi/schedule/api?",
                   service.endpoint)
    end

    test 'with query' do
      opts = {
        garoon_endpoint: "http://example.com/cgi?p1=val&p2=val",
        garoon_username: "username",
        garoon_password: "password",
        garoon_version:  3
      }
      Ragoon.class_variable_set :@@secret_options, opts
      service = Ragoon::Services::Schedule.new
      assert_equal("http://example.com/cgi/cbpapi/schedule/api?",
                   service.endpoint)
    end

    test 'by argument' do
      service = Ragoon::Services::Schedule.new(
        endpoint: "http://example.com/by_arg",
        username: "username",
        password: "password",
        version:  3
      )
      assert_equal("http://example.com/by_arg/cbpapi/schedule/api?",
                   service.endpoint)
    end

    teardown do
      ENV.delete('GAROON_ENDPOINT')
      ENV.delete('GAROON_USERNAME')
      ENV.delete('GAROON_PASSWORD')
      ENV.delete('GAROON_VERSION')
      Ragoon.class_variable_set :@@secret_options, {}
    end
  end

  sub_test_case '#garoon_endpoint' do
    setup do
      ENV['GAROON_ENDPOINT'] = "http://example.com/by_env"
      ENV['GAROON_USERNAME'] = "username"
      ENV['GAROON_PASSWORD'] = "password"
      ENV['GAROON_VERSION']  = '3'
      @service = Ragoon::Services::Schedule.new
    end

    test 'returns correct endpoint URL' do
      assert_equal(@service.garoon_endpoint, ENV['GAROON_ENDPOINT'])
    end

    teardown do
      ENV.delete('GAROON_ENDPOINT')
      ENV.delete('GAROON_USERNAME')
      ENV.delete('GAROON_PASSWORD')
      ENV.delete('GAROON_VERSION')
    end
  end
end
