class CashEntriesController < ApplicationController
  before_action :set_entry, only: %i[edit update destroy]

  def create
    entry = CashEntry.new(entry_params.merge(created_by: current_user))
    if entry.save
      redirect_to month_path(entry.entry_on), notice: "#{entry.kind.capitalize} saved."
    else
      redirect_back fallback_location: cash_record_path, alert: entry.errors.full_messages.to_sentence
    end
  end

  def edit; end

  def update
    if @entry.update(entry_params)
      redirect_to month_path(@entry.entry_on), notice: "Entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy!
    redirect_to month_path(@entry.entry_on), notice: "Entry deleted."
  end

  private

  def set_entry = @entry = CashEntry.find(params[:id])
  def month_path(date) = cash_record_path(month: date.strftime("%Y-%m"))

  def entry_params
    params.require(:cash_entry).permit(:entry_on, :kind, :description, :category, :reference, :amount_text, :offering_type_id)
  end
end
