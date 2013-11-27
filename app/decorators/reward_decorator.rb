class RewardDecorator < Draper::Decorator
  decorates :reward
  include Draper::LazyHelpers

  def display_deliver_prevision
    I18n.l((source.project.expires_at + source.days_to_delivery.days), format: :prevision)
  rescue
    source.days_to_delivery
  end

  def display_remaining
    I18n.t('reward.display_remaining', remaining: source.remaining, maximum: source.maximum_backers).html_safe
  end

  def display_minimum
    number_to_currency source.minimum_value, precision: 0
  end

  def short_description
    truncate source.description, length: 35
  end

  def display_description
    auto_link(simple_format(source.description), html: {target: :blank})
  end
end
