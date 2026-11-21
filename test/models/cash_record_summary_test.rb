require "test_helper"

class CashRecordSummaryTest < ActiveSupport::TestCase
  test "closing balance and LDF when LDF stays in the account" do
    s = CashRecord.summarize(brought_forward: 50_000, receipts: 120_000, payments: 30_000,
                             ldf_base: 100_000, ldf_percent: 10, deduct_ldf: false,
                             petty_cash: 40_000, bank_balance: 100_000)
    assert_equal 10_000, s.ldf
    assert_equal 90_000, s.remittable
    assert_equal 140_000, s.closing
    assert_equal 140_000, s.counted
    assert_equal 0, s.difference
  end

  test "LDF deducted from cash" do
    s = CashRecord.summarize(brought_forward: 0, receipts: 100_000, payments: 0,
                             ldf_base: 100_000, ldf_percent: 10, deduct_ldf: true)
    assert_equal 90_000, s.closing
    assert_nil s.counted
    assert_nil s.difference
  end

  test "difference shows a shortfall" do
    s = CashRecord.summarize(brought_forward: 10_000, receipts: 5_000, payments: 0,
                             ldf_base: 5_000, ldf_percent: 10, deduct_ldf: false,
                             petty_cash: 2_000, bank_balance: 12_000)
    assert_equal(-1_000, s.difference)
  end
end
