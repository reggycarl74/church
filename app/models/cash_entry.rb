class CashEntry < ApplicationRecord
  KINDS = %w[income expense].freeze
  EXPENSE_CATEGORIES = [ "Rent", "Utilities", "Transport", "Welfare", "Hospitality", "Office supplies",
                         "Bank charges", "Remittance", "Other" ].freeze

  belongs_to :offering_type, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  validates :entry_on, :description, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validate { errors.add(:offering_type, "only applies to income") if kind == "expense" && offering_type_id.present? }

  scope :in_range, ->(range) { where(entry_on: range) }
  scope :income, -> { where(kind: "income") }
  scope :expense, -> { where(kind: "expense") }

  attr_writer :amount_text
  def amount_text = @amount_text || (amount_cents ? Money.plain(amount_cents) : "")

  before_validation do
    if @amount_text
      begin
        self.amount_cents = Money.parse(@amount_text)
      rescue ArgumentError
        errors.add(:amount_text, "is not a valid amount")
        self.amount_cents = nil
      end
    end
    self.offering_type_id = nil if kind == "expense"
  end
end
