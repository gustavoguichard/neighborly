class ContributionReportsForProjectOwner
=begin
SELECT b.project_id,
       COALESCE(r.id, 0) AS reward_id,
       r.description AS reward_description,
       to_char(r.minimum_value, 'FM999999999'::text) AS reward_minimum_value,
       to_char(b.created_at, 'HH12:MIam DD Mon YY'::text) AS created_at,
       to_char(b.confirmed_at, 'HH12:MIam DD Mon YY'::text) AS confirmed_at,
       to_char(b.value, 'FM999999999'::text) AS contribution_value,
       u.email AS user_email,
       u.name AS user_name,
       b.payer_email,
       b.payment_method,
       COALESCE(b.address_street, u.address_street) AS street,

       COALESCE(b.address_complement, u.address_complement) AS complement,
       COALESCE(b.address_number, u.address_number) AS address_number,
       COALESCE(b.address_neighborhood, u.address_neighborhood) AS neighborhood,
       COALESCE(b.address_city, u.address_city) AS city,
       COALESCE(b.address_state, u.address_state) AS STATE,
       COALESCE(b.address_zip_code, u.address_zip_code) AS zip_code,
       b.anonymous,
       b.short_note
FROM ((contributions b
       JOIN users u ON ((u.id = b.user_id)))
      LEFT JOIN rewards r ON ((r.id = b.reward_id)))
WHERE ((b.STATE)::text = 'confirmed'::text)
ORDER BY b.confirmed_at,
         b.id
=end
  include ActiveModel::Serialization
  include Enumerable

  attr_accessor :project, :conditions

  def initialize(project, conditions = {})
    @project, @conditions = project, conditions
  end

  def all
    contributions
  end

  def each(&block)
    contributions.each do |contribution|
      block.call(contribution)
    end
  end

  private

  def contributions
    @contributions ||= project.contributions.with_state(:confirmed).where(conditions).map do |c|
      ContributionForProjectOwner.new(c)
    end
  end
end
