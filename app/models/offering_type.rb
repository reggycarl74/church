class OfferingType < ApplicationRecord
  has_many :contributions, dependent: :restrict_with_error
  has_many :cash_entries, dependent: :nullify
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  default_scope { order(:position, :id) }
  scope :active, -> { where(active: true) }
end
