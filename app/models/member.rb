class Member < ApplicationRecord
  belongs_to :section
  has_many :contributions, dependent: :restrict_with_error
  validates :name, presence: true
  scope :active, -> { where(active: true) }

  before_create do
    self.position = (section.members.maximum(:position) || -1) + 1
  end
end
