class SettingsController < ApplicationController
  before_action :require_admin, only: %i[update backup]

  def edit; end

  def update
    if setting.update(params.require(:setting).permit(:church_name, :currency, :collection_wday, :ldf_percent, :deduct_ldf))
      redirect_to edit_settings_path, notice: "Settings saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Consistent copy of the whole SQLite database (all names, amounts and cash records).
  def backup
    path = Rails.root.join("tmp", "backup-#{SecureRandom.hex(6)}.sqlite3")
    ActiveRecord::Base.connection.execute("VACUUM INTO #{ActiveRecord::Base.connection.quote(path.to_s)}")
    data = File.binread(path)
    send_data data, filename: "altona-finance-#{Date.current.iso8601}.sqlite3", type: "application/vnd.sqlite3"
  ensure
    File.delete(path) if path && File.exist?(path)
  end
end
