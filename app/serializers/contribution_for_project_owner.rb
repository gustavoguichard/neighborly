class ContributionForProjectOwner < ActiveModel::Serializer
  attr_accessor :contribution

  attributes :user, :reward, :anonymous, :confirmed_at, :contribution_value,
    :created_at, :payer_email, :payment_method, :short_note,
    :reward_description, :reward_minimum_value, :user_email, :user_name

  delegate :user, :reward, :anonymous, :created_at, :confirmed_at,
    :payer_email, :payment_method, :short_note, to: :contribution, allow_nil: true
  delegate :value, to: :contribution, prefix: true, allow_nil: true
  delegate :email, :name, to: :user, prefix: true, allow_nil: true
  delegate :description, :minimum_value, to: :reward, prefix: true, allow_nil: true

  def initialize(contribution)
    @contribution = contribution
  end

  def reward_id
    reward.id || 0
  end

  def street
    contribution.address_street || user.address_street
  end

  def complement
    contribution.address_complement || user.address_complement
  end

  def address_number
    contribution.address_number || user.address_number
  end

  def neighborhood
    contribution.address_neighborhood || user.address_neighborhood
  end

  def city
    contribution.address_city || user.address_city
  end

  def state
    contribution.address_state || user.address_state
  end

  def zip_code
    contribution.address_zip_code || user.address_zip_code
  end
end
