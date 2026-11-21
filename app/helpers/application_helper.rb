module ApplicationHelper
  def money(cents) = Money.format(cents.to_i, setting.currency)
  def money_plain(cents, blank_zero: true) = Money.plain(cents.to_i, blank_zero: blank_zero)
  def month_param(date) = date.strftime("%Y-%m")
  def month_title(date) = date.strftime("%B %Y")
  def day_label(date) = date.strftime("%d.%m.")

  def nav_link(label, path, active)
    link_to label, path, class: [ "nav-link", ("active" if active) ]
  end

  def signed_class(cents)
    cents.to_i.negative? ? "neg" : nil
  end
end
