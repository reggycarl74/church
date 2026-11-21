require "csv"

class SheetsController < ApplicationController
  def show
    @types = OfferingType.active.to_a
    @type = params[:type] == "all" ? nil : (OfferingType.find_by(id: params[:type]) || @types.first)
    @sheet = TithesSheet.new(selected_month.year, selected_month.month, @type, setting)

    respond_to do |format|
      format.html
      format.csv do
        send_data sheet_csv, filename: "tithes-#{selected_month.strftime('%Y-%m')}.csv", type: "text/csv; charset=utf-8"
      end
    end
  end

  private

  # One row per member and offering type (all types), semicolon-separated for German Excel.
  def sheet_csv
    types = OfferingType.active.to_a
    sheets = types.to_h { |t| [ t, TithesSheet.new(selected_month.year, selected_month.month, t, setting) ] }
    days = sheets.values.first&.days || []
    "﻿" + CSV.generate(col_sep: ";") do |csv|
      csv << [ "Section", "Name", "Type", *days.map { |d| d.strftime("%d.%m.%Y") }, "Month total" ]
      Section.includes(:members).each do |section|
        section.members.each do |m|
          types.each do |t|
            s = sheets[t]
            csv << [ section.name, m.name, t.name, *days.map { |d| Money.plain(s.amount(m, d)) }, Money.plain(s.member_total(m)) ]
          end
        end
      end
      types.each do |t|
        s = sheets[t]
        csv << [ "TOTAL", "", t.name, *days.map { |d| Money.plain(s.day_total(d)) }, Money.plain(s.grand_total) ]
      end
    end
  end
end
