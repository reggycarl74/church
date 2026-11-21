# Works out the collection days (Sundays by default) of a month and which
# week column a given date belongs to.
class CollectionCalendar
  attr_reader :year, :month, :wday

  def initialize(year, month, wday = 0)
    @year, @month, @wday = year.to_i, month.to_i, wday.to_i
  end

  def first_day = Date.new(year, month, 1)
  def last_day  = first_day.end_of_month
  def range     = first_day..last_day

  def days
    @days ||= range.select { |d| d.wday == wday }
  end

  # Index of the week column for a date: the last collection day on or
  # before the date; dates before the first collection day go to week 0.
  def week_index(date)
    idx = days.rindex { |d| d <= date }
    idx || 0
  end

  def label(date) = date.strftime("%d.%m.")
end
