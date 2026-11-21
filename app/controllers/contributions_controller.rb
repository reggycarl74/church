# Receives one cell from the sheet (autosave) and returns the stored value.
class ContributionsController < ApplicationController
  def upsert
    member = Member.find(params[:member_id])
    type = OfferingType.find(params[:offering_type_id])
    date = Date.iso8601(params[:date].to_s)
    cents = Money.parse(params[:amount])
    return render(json: { error: "Amount cannot be negative" }, status: :unprocessable_entity) if cents.negative?

    Contribution.set_amount!(member: member, offering_type: type, date: date, cents: cents, user: current_user)
    render json: { amount: Money.plain(cents, blank_zero: true), cents: cents }
  rescue ArgumentError, Date::Error
    render json: { error: "Invalid amount — use e.g. 20 or 12,50" }, status: :unprocessable_entity
  end
end
