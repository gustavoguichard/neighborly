class ProjectTotal
=begin
SELECT contributions.project_id,
       sum(contributions.value) AS pledged,
       ((sum(contributions.value) / projects.goal) * (100)::numeric) AS progress,
       sum(contribution_fees.payment_service_fee) AS total_payment_service_fee,
       count(*) AS total_contributions,
       (sum(contributions.value) *
          (SELECT (configurations.value)::numeric AS value
           FROM configurations
           WHERE (configurations.name = 'platform_fee'::text))) AS platform_fee,
       (sum(contribution_fees.net_payment) - (sum(contributions.value) *
                                                (SELECT (configurations.value)::numeric AS value
                                                 FROM configurations
                                                 WHERE (configurations.name = 'platform_fee'::text)))) AS net_amount
FROM ((contributions
       JOIN projects ON ((contributions.project_id = projects.id)))
      JOIN contribution_fees ON ((contribution_fees.id = contributions.id)))
WHERE ((contributions.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
GROUP BY contributions.project_id,
         projects.goal
=end

  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def net_amount
    contributions.inject(0) { |sum, c| sum + c.net_payment } - platform_fee
  end

  def platform_fee
    pledged * Configuration[:platform_fee]
  end

  def pledged
    contributions.sum(:value)
  end

  def progress
    pledged / projects.goal * 100
  end

  def total_contributions
    contributions.length
  end

  def total_payment_service_fee
    contributions.inject(0) { |sum, c| sum + c.payment_service_fee }
  end

  private

  def contributions
    project.contributions.with_state(:confirmed, :refunded, :requested_refund)
  end
end
