class ProjectFinancialsByService
=begin
SELECT contributions.project_id,
       contributions.payment_method,
       (contribution_fees.net_payment - (sum(contributions.value) *
                                           (SELECT (configurations.value)::numeric AS value
                                            FROM configurations
                                            WHERE (configurations.name = 'platform_fee'::text)))) AS net_amount,
       (sum(contributions.value) *
          (SELECT (configurations.value)::numeric AS value
           FROM configurations
           WHERE (configurations.name = 'platform_fee'::text))) AS platform_fee,
       sum(contributions.payment_service_fee) AS payment_service_fee,
       count(*) AS total_contributions
FROM ((contributions
       JOIN projects ON ((contributions.project_id = projects.id)))
      JOIN contribution_fees ON ((contributions.id = contribution_fees.id)))
WHERE ((contributions.state)::text = 'confirmed'::text)
GROUP BY contributions.project_id,
         contributions.payment_method,
         contribution_fees.net_payment HAVING (contributions.payment_method IS NOT NULL)
=end

  include Enumerable

  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def each(&block)
    services.each do |service|
      block.call(service)
    end
  end

  def net_amount
    sum(&:net_amount)
  end

  def payment_service_fee
    sum(&:payment_service_fee)
  end

  def platform_fee
    sum(&:platform_fee)
  end

  def total_contributions
    sum(&:total_contributions)
  end

  private

  def services
    @services ||= Contribution.where(project: project).
      uniq.pluck(:payment_method).map do |service|
      ProjectFinancialByService.new(project, service)
    end
  end
end
