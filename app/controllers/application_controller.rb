class ApplicationController < ActionController::Base
  include Authentication

  private

  def setting = @setting ||= Setting.current
  helper_method :setting

  # Month from params[:month] ("2026-11"), defaults to the current month.
  def selected_month
    @selected_month ||= begin
      y, m = params[:month].to_s.split("-").map(&:to_i)
      (y.to_i > 2000 && (1..12).cover?(m)) ? Date.new(y, m, 1) : Date.current.beginning_of_month
    end
  end
  helper_method :selected_month
end
