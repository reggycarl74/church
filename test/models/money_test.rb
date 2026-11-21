require "test_helper"

class MoneyTest < ActiveSupport::TestCase
  test "parses German and English formats" do
    assert_equal 2000, Money.parse("20")
    assert_equal 1250, Money.parse("12,50")
    assert_equal 1250, Money.parse("12.50")
    assert_equal 1250, Money.parse("12,5")
    assert_equal 123456, Money.parse("1.234,56")
    assert_equal 123456, Money.parse("1,234.56")
    assert_equal 2000, Money.parse("€ 20")
    assert_equal 0, Money.parse("")
    assert_equal(-500, Money.parse("-5"))
  end

  test "rejects nonsense" do
    assert_raises(ArgumentError) { Money.parse("abc") }
    assert_raises(ArgumentError) { Money.parse("12,345") } # three decimals is ambiguous
  end

  test "formats" do
    assert_equal "1.234,56", Money.plain(123456)
    assert_equal "0,05", Money.plain(5)
    assert_equal "", Money.plain(0, blank_zero: true)
    assert_equal "-12,00", Money.plain(-1200)
    assert_equal "20,00 €", Money.format(2000, "EUR")
  end

  test "percent rounds half up to cents" do
    assert_equal 12345, Money.percent(123450, 10)
    assert_equal 1, Money.percent(5, 10) # 0.5 cent -> 1 cent
    assert_equal 0, Money.percent(4, 10)
  end
end
