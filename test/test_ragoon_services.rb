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
end
