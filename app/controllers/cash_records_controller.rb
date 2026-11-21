class CashRecordsController < ApplicationController
  def show
    @record = CashRecord.new(selected_month.year, selected_month.month, setting)
    @cash_month = @record.cash_month
    @new_income = CashEntry.new(kind: "income", entry_on: default_entry_date)
    @new_expense = CashEntry.new(kind: "expense", entry_on: default_entry_date)
  end

  # Saves the hand-entered month figures (cash b/f override, petty cash, bank balance, notes)
  def update
    @cash_month = CashMonth.for(selected_month.year, selected_month.month)
    @cash_month.assign_attributes(params.require(:cash_month).permit(:brought_forward_override_text, :petty_cash_text, :bank_balance_text, :notes))
    if @cash_month.save
      redirect_to cash_record_path(month: selected_month.strftime("%Y-%m")), notice: "Month figures saved."
    else
      redirect_to cash_record_path(month: selected_month.strftime("%Y-%m")), alert: @cash_month.errors.full_messages.to_sentence
    end
  end

  private

  def default_entry_date
    today = Date.current
    (selected_month..selected_month.end_of_month).cover?(today) ? today : selected_month
  end
end
