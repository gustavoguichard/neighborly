class ContributionDecorator < Draper::Decorator
  decorates :contribution
  include Draper::LazyHelpers

  def display_value
    amount  = source.value
    if source.payment_service_fee_paid_by_user
      amount += source.payment_service_fee
    end
    number_to_currency(amount)
  end

  def display_confirmed_at
    I18n.l(source.confirmed_at.to_date) if source.confirmed_at
  end
end

