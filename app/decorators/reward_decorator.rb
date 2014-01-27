class RewardDecorator < Draper::Decorator
  decorates :reward
  include Draper::LazyHelpers
  include AutoHtml

  def display_deliver_prevision
    I18n.l((source.project.expires_at + source.days_to_delivery.days), format: :prevision) rescue source.days_to_delivery
  end

  def display_remaining
    I18n.t('reward.display_remaining', remaining: source.remaining, maximum: source.maximum_contributions).html_safe
  end

  def display_minimum
    number_to_currency source.minimum_value, precision: 0
  end

  def display_description
    auto_html(source.description) { simple_format; link(target: :blank) }
  end
end
