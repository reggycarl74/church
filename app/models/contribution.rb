class Contribution < ApplicationRecord
  belongs_to :member
  belongs_to :offering_type
  belongs_to :updated_by, class_name: "User", optional: true
  validates :given_on, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :in_range, ->(range) { where(given_on: range) }

  # Sets (or clears, when zero) the amount for one cell of the sheet.
  def self.set_amount!(member:, offering_type:, date:, cents:, user: nil)
    record = find_or_initialize_by(member: member, offering_type: offering_type, given_on: date)
    if cents.zero?
      record.destroy! if record.persisted?
      nil
    else
      record.update!(amount_cents: cents, updated_by: user)
      record
    end
  end
end
