class RewardDecorator < Draper::Decorator
  decorates :reward
  include Draper::LazyHelpers

  def to_s
    source.happens_at.to_s
  end

  def display_remaining
    I18n.t('reward.display_remaining', remaining: source.remaining, maximum: source.maximum_contributions).html_safe
  end
end
