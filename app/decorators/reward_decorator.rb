class RewardDecorator < Draper::Decorator
  decorates :reward
  include Draper::LazyHelpers

  def to_s
    interest = if source.try(:interest_rate)
      ' - ' + sprintf('%.4g%', source.interest_rate)
    else
      ''
    end
    source.happens_at.to_s + interest
  end

  def display_remaining
    I18n.t('reward.display_remaining', remaining: source.remaining, maximum: source.maximum_contributions).html_safe
  end
end
