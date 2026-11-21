# Stores the figures entered by hand for a month: an optional override for
# cash brought forward, and the counted petty cash and bank balance.
class CashMonth < ApplicationRecord
  validates :year, :month, presence: true
  validates :month, inclusion: { in: 1..12 }

  MONEY_FIELDS = %i[brought_forward_override_cents petty_cash_cents bank_balance_cents].freeze

  MONEY_FIELDS.each do |field|
    text_attr = field.to_s.sub(/_cents\z/, "_text")
    define_method(text_attr) do
      v = public_send(field)
      v.nil? ? "" : Money.plain(v)
    end
    define_method("#{text_attr}=") do |text|
      public_send("#{field}=", text.to_s.strip.empty? ? nil : Money.parse(text))
    rescue ArgumentError
      (@invalid_amounts ||= []) << text_attr
    end
  end

  validate { Array(@invalid_amounts).uniq.each { |a| errors.add(a, "is not a valid amount") } }

  def self.for(year, month)
    find_or_initialize_by(year: year, month: month)
  end
end
