class Section < ApplicationRecord
  has_many :members, -> { order(:position, :name) }, dependent: :restrict_with_error
  validates :name, presence: true
  default_scope { order(:position, :id) }

  before_create { self.position = (Section.maximum(:position) || -1) + 1 if position.to_i.zero? && Section.exists? }
end
