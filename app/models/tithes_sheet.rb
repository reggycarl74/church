# Data for the one-page tithes & offerings sheet of a month.
class TithesSheet
  attr_reader :calendar, :offering_type

  # offering_type: an OfferingType, or nil for "all types added together"
  def initialize(year, month, offering_type, setting = Setting.current)
    @calendar = CollectionCalendar.new(year, month, setting.collection_wday)
    @offering_type = offering_type
  end

  delegate :days, :range, to: :calendar

  def summary? = offering_type.nil?
  def sections = @sections ||= Section.includes(:members).to_a

  def members_of(section)
    section.members.select { |m| m.active || amounts.keys.any? { |(mid, _)| mid == m.id } }
  end

  # { [member_id, date] => cents }
  def amounts
    @amounts ||= begin
      scope = Contribution.in_range(range)
      scope = scope.where(offering_type_id: offering_type.id) if offering_type
      scope.group(:member_id, :given_on).sum(:amount_cents)
    end
  end

  def amount(member, day) = amounts[[ member.id, day ]].to_i
  def member_total(member) = days.sum { |d| amount(member, d) }
  def section_day_total(section, day) = members_of(section).sum { |m| amount(m, day) }
  def section_total(section) = days.sum { |d| section_day_total(section, d) }
  def day_total(day) = sections.sum { |s| section_day_total(s, day) }
  def grand_total = days.sum { |d| day_total(d) }
end
