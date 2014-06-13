class ContributionReport
=begin
SELECT b.project_id,
 u.name,
 b.value,
 r.minimum_value,
 r.description,
 b.payment_method,
 b.payment_choice,
 fees.payment_service_fee,
 b.key,
 (b.created_at)::date AS created_at,
 (b.confirmed_at)::date AS confirmed_at,
 u.email,
 b.payer_email,
 b.payer_name,
 b.payer_document,
 u.address_street,
 u.address_complement,
 u.address_number,
 u.address_neighborhood AS address_neighbourhood,
 u.address_city,
 u.address_state,
 u.address_zip_code,
 b.state
((contributions b
  JOIN users u ON ((u.id = b.user_id)))
 LEFT JOIN rewards r ON ((r.id = b.reward_id)))
JOIN contributions_fees fees ON ((fees.id = b.id)))
WHERE ((b.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
=end

  extend Enumerable

  attr_accessor :contribution

  delegate :reward, :confirmed_at, :created_at, :key, :payer_document, :payer_email, :payer_name, :payment_choice, :payment_method, :payment_service_fee, :project_id, :state, :value, to: :contribution

  delegate :description, :minimum_value, to: :reward

  delegate :address_city, :address_complement, :address_neighborhood,
    :address_number, :address_state, :address_street, :address_zip_code,
    :email, :name, to: :user

  alias_method :address_neighbourhood, :address_neighborhood

  def initialize(contribution)
    @contribution = contribution
  end

  def self.each(&block)
    contributions.each do |contribution|
      block.call(contribution)
    end
  end

  private

  def self.contributions
    @contributions ||= Contribution.with_state(:confirmed, :refunded, :requested_refund).
      map do |contribution|
      new(contribution)
    end
  end
end
