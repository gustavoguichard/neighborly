class ContributionForProjectOwner
  include ActiveModel::Serialization

  attr_accessor :contribution

  delegate :user, :reward, :anonymous, :created_at, :confirmed_at,
    :payer_email, :payment_method, :project_id, :short_note, to: :contribution,
    allow_nil: true
  delegate :value, to: :contribution, prefix: true, allow_nil: true
  delegate :email, :name, to: :user, prefix: true, allow_nil: true
  delegate :description, :minimum_value, to: :reward, prefix: true, allow_nil: true

  def initialize(contribution)
    @contribution = contribution
  end

  def attributes
    {
      project_id:           project_id,
      reward_id:            reward_id,
      reward_description:   reward_description,
      reward_minimum_value: reward_minimum_value,
      created_at:           created_at,
      confirmed_at:         confirmed_at,
      contribution_value:   contribution_value,
      user_email:           user_email,
      user_name:            user_name,
      payer_email:          payer_email,
      payment_method:       payment_method,
      street:               street,
      complement:           complement,
      address_number:       address_number,
      neighborhood:         neighborhood,
      city:                 city,
      state:                state,
      zip_code:             zip_code,
      anonymous:            anonymous,
      short_note:           short_note
    }
  end

  def address_number
    contribution.address_number || user.address_number
  end

  def complement
    contribution.address_complement || user.address_complement
  end

  def city
    contribution.address_city || user.address_city
  end

  def neighborhood
    contribution.address_neighborhood || user.address_neighborhood
  end

  def reward_id
    reward.try(:id) || 0
  end

  def state
    contribution.address_state || user.address_state
  end

  def street
    contribution.address_street || user.address_street
  end

  def zip_code
    contribution.address_zip_code || user.address_zip_code
  end
end
