# Amounts are stored as integer cents. This module converts between text and cents
# without floating-point errors. Accepts "12", "12,50", "12.50", "1.234,56", "1,234.56", "€ 20".
module Money
  module_function

  def parse(text)
    s = text.to_s.strip.gsub(/[€$£\s]|EUR/i, "")
    return 0 if s.empty?
    negative = s.start_with?("-")
    s = s.delete_prefix("-")
    if s.include?(",") && s.include?(".")
      s = s.rindex(",") > s.rindex(".") ? s.delete(".").tr(",", ".") : s.delete(",")
    elsif s.include?(",")
      s = s.tr(",", ".")
    end
    raise ArgumentError, "Invalid amount: #{text}" unless s.match?(/\A\d+(\.\d{1,2})?\z|\A\.\d{1,2}\z/)
    whole, frac = s.split(".")
    cents = whole.to_i * 100 + (frac.to_s.ljust(2, "0")).to_i
    negative ? -cents : cents
  end

  # 123456 -> "1.234,56"
  def plain(cents, blank_zero: false)
    return "" if blank_zero && cents.to_i.zero?
    sign = cents.to_i.negative? ? "-" : ""
    whole, frac = cents.to_i.abs.divmod(100)
    "#{sign}#{whole.to_s.reverse.scan(/\d{1,3}/).join('.').reverse},#{frac.to_s.rjust(2, '0')}"
  end

  SYMBOLS = { "EUR" => "€", "USD" => "$", "GBP" => "£", "CHF" => "CHF", "GHS" => "GH₵" }.freeze

  def format(cents, currency = "EUR")
    "#{plain(cents)} #{SYMBOLS.fetch(currency, currency)}"
  end

  # percentage of an amount, rounded half up to whole cents
  def percent(cents, pct)
    (BigDecimal(cents.to_s) * BigDecimal(pct.to_s) / 100).round(0, BigDecimal::ROUND_HALF_UP).to_i
  end
end
