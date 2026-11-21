require "test_helper"

class CollectionCalendarTest < ActiveSupport::TestCase
  test "Sundays of November 2026" do
    cal = CollectionCalendar.new(2026, 11, 0)
    assert_equal [ 1, 8, 15, 22, 29 ], cal.days.map(&:day)
  end

  test "dates are bucketed into the week of the last collection day" do
    cal = CollectionCalendar.new(2026, 12, 0) # Sundays: 6, 13, 20, 27
    assert_equal 0, cal.week_index(Date.new(2026, 12, 1)) # before the first Sunday
    assert_equal 0, cal.week_index(Date.new(2026, 12, 6))
    assert_equal 0, cal.week_index(Date.new(2026, 12, 12))
    assert_equal 1, cal.week_index(Date.new(2026, 12, 13))
    assert_equal 3, cal.week_index(Date.new(2026, 12, 31))
  end
end
