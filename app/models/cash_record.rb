# The monthly cash record: receipts and payments per week, LDF,
# cash brought forward, closing balance and petty cash / bank reconciliation.
class CashRecord
  Summary = Struct.new(:brought_forward, :receipts, :payments, :ldf_base, :ldf_percent, :ldf,
                       :deduct_ldf, :closing, :petty_cash, :bank_balance, :counted, :difference,
                       :remittable, keyword_init: true)

  # Pure calculation, kept separate so it can be tested without a database.
  def self.summarize(brought_forward:, receipts:, payments:, ldf_base:, ldf_percent:, deduct_ldf:,
                     petty_cash: nil, bank_balance: nil)
    ldf = Money.percent(ldf_base, ldf_percent)
    closing = brought_forward + receipts - payments - (deduct_ldf ? ldf : 0)
    counted = petty_cash.nil? && bank_balance.nil? ? nil : petty_cash.to_i + bank_balance.to_i
    Summary.new(
      brought_forward:, receipts:, payments:, ldf_base:, ldf_percent:, ldf:, deduct_ldf:, closing:,
      petty_cash:, bank_balance:, counted:,
      difference: counted && counted - closing,
      remittable: ldf_base - ldf
    )
  end

  attr_reader :calendar, :setting

  def initialize(year, month, setting = Setting.current)
    @setting = setting
    @calendar = CollectionCalendar.new(year, month, setting.collection_wday)
  end

  delegate :days, :range, :year, :month, to: :calendar

  def cash_month = @cash_month ||= CashMonth.for(year, month)
  def weeks = days.size.nonzero? || 1
  def zeros = Array.new(weeks, 0)

  # { OfferingType => [cents per week] } from the tithes sheet plus typed income entries
  def receipts_by_type
    @receipts_by_type ||= begin
      sums = Hash.new { |h, k| h[k] = zeros }
      Contribution.in_range(range).group(:offering_type_id, :given_on).sum(:amount_cents).each do |(type_id, date), cents|
        sums[type_id][calendar.week_index(date)] += cents
      end
      CashEntry.income.in_range(range).where.not(offering_type_id: nil).each do |e|
        sums[e.offering_type_id][calendar.week_index(e.entry_on)] += e.amount_cents
      end
      types = OfferingType.where(id: sums.keys).or(OfferingType.active).to_a
      types.to_h { |t| [ t, sums.key?(t.id) ? sums[t.id] : zeros ] }
    end
  end

  def sheet_by_type_for(type_id)
    Contribution.in_range(range).where(offering_type_id: type_id).sum(:amount_cents)
  end

  def income_entries  = @income_entries  ||= CashEntry.income.in_range(range).includes(:offering_type).order(:entry_on, :id).to_a
  def expense_entries = @expense_entries ||= CashEntry.expense.in_range(range).order(:entry_on, :id).to_a

  def other_income_by_week
    @other_income_by_week ||= income_entries.reject(&:offering_type_id).each_with_object(zeros) do |e, w|
      w[calendar.week_index(e.entry_on)] += e.amount_cents
    end
  end

  # { "Rent" => [cents per week] }
  def expenses_by_category
    @expenses_by_category ||= expense_entries.each_with_object(Hash.new { |h, k| h[k] = zeros }) do |e, h|
      h[e.category.presence || "Other"][calendar.week_index(e.entry_on)] += e.amount_cents
    end
  end

  def receipts_by_week
    receipts_by_type.values.push(other_income_by_week).transpose.map(&:sum)
  end

  def payments_by_week
    rows = expenses_by_category.values
    rows.empty? ? zeros : rows.transpose.map(&:sum)
  end

  def ldf_base
    receipts_by_type.select { |t, _| t.counts_for_ldf }.values.flatten.sum
  end

  def summary
    @summary ||= self.class.summarize(
      brought_forward: brought_forward,
      receipts: receipts_by_week.sum,
      payments: payments_by_week.sum,
      ldf_base: ldf_base,
      ldf_percent: setting.ldf_percent,
      deduct_ldf: setting.deduct_ldf,
      petty_cash: cash_month.petty_cash_cents,
      bank_balance: cash_month.bank_balance_cents
    )
  end

  def closing = summary.closing

  # Previous month's closing balance, unless entered by hand for this month.
  def brought_forward
    return cash_month.brought_forward_override_cents unless cash_month.brought_forward_override_cents.nil?

    prev = calendar.first_day.prev_month
    start = self.class.earliest_month
    return 0 if start.nil? || prev < start

    self.class.new(prev.year, prev.month, setting).closing
  end

  def brought_forward_is_override? = !cash_month.brought_forward_override_cents.nil?

  def self.earliest_month
    candidates = [ Contribution.minimum(:given_on), CashEntry.minimum(:entry_on) ]
    first_cm = CashMonth.order(:year, :month).first
    candidates << Date.new(first_cm.year, first_cm.month, 1) if first_cm
    candidates.compact.min&.beginning_of_month
  end
end
