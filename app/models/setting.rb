class Setting < ApplicationRecord
  CURRENCIES = %w[EUR USD GBP CHF GHS].freeze
  WEEKDAYS = { "Sunday" => 0, "Saturday" => 6, "Friday" => 5, "Monday" => 1 }.freeze

  validates :church_name, presence: true
  validates :currency, inclusion: { in: CURRENCIES }
  validates :ldf_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :collection_wday, inclusion: { in: 0..6 }

  def self.current
    first || create!
  end
end
