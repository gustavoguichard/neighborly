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
    # from match => "payment_token"=>nil, "payment_id"=>nil, "payer_name"=>nil, "payer_email"=>nil, "payer_document"=>nil, "payment_choice"=>nil, "payment_service_fee"=>, 'payment_service_fee_paid_by_user'
    @attributes.merge!(
      match.attributes.slice('user_id')
    )
  end
end
