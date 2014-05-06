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

  def build_attributes
    @attributes[:payment_method] = :matched
    @attributes[:value]          = contribution.value * match.value_unit

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
      match.attributes.slice('user_id')
    )
  end
end
