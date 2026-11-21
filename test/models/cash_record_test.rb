require "test_helper"

class CashRecordTest < ActiveSupport::TestCase
  setup do
    @setting = Setting.current
    @tithe = OfferingType.create!(name: "Tithe", counts_for_ldf: true)
    @welfare = OfferingType.create!(name: "Welfare", counts_for_ldf: false)
    section = Section.create!(name: "Members")
    @kofi = section.members.create!(name: "Kofi")
  end

  test "pulls sheet amounts per week, computes LDF and carries the balance forward" do
    CashMonth.create!(year: 2026, month: 11, brought_forward_override_cents: 10_000)
    Contribution.set_amount!(member: @kofi, offering_type: @tithe, date: Date.new(2026, 11, 1), cents: 20_000)
    Contribution.set_amount!(member: @kofi, offering_type: @welfare, date: Date.new(2026, 11, 8), cents: 5_000)
    CashEntry.create!(kind: "income", entry_on: Date.new(2026, 11, 8), description: "Loose offering", amount_text: "30", offering_type: @tithe)
    CashEntry.create!(kind: "expense", entry_on: Date.new(2026, 11, 10), description: "Rent", category: "Rent", amount_text: "100")

    nov = CashRecord.new(2026, 11, @setting)
    assert_equal [ 20_000, 3_000, 0, 0, 0 ], nov.receipts_by_type[@tithe]
    assert_equal 2_300, nov.summary.ldf # 10% of 230 €
    assert_equal 10_000 + 28_000 - 10_000, nov.closing

    dec = CashRecord.new(2026, 12, @setting)
    assert_equal nov.closing, dec.brought_forward
  end
end
