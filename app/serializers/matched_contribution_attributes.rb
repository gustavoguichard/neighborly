class MatchedContributionAttributes
  attr_reader :contribution, :match

  def initialize(contribution, match)
    @attributes   = {}.with_indifferent_access
    @contribution = contribution
    @match        = match
  end

  def attributes
    build_attributes
  end

  protected

  def value
    [
      contribution.value * match.value_unit,
      match.remaining_amount
    ].min
  end

  def build_attributes
    @attributes[:payment_method] = :matched
    @attributes[:value]          = value

    build_attributes_from_contribution
    build_attributes_from_match

    @attributes
  end

  def build_attributes_from_contribution
    @attributes.merge!(
      contribution.attributes.slice('project_id', 'state')
    )
  end

  def build_attributes_from_match
    @attributes.merge!(
      match.attributes.slice('user_id', 'payment_service_fee_paid_by_user')
    )
  end
end
