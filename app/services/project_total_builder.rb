class ProjectTotalBuilder
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def attributes
    {
      net_amount:                          net_amount,
      platform_fee:                        platform_fee,
      pledged:                             pledged,
      progress:                            progress,
      total_contributions:                 total_contributions,
      total_contributions_without_matches: total_contributions_without_matches,
      total_payment_service_fee:           total_payment_service_fee
    }
  end

  def perform
    ProjectTotal.find_or_create_by(project_id: project.id).
      update_attributes(attributes)
  end

  private

  def contributions
    project.contributions.with_state(:confirmed, :refunded, :requested_refund)
  end

  def net_amount
    contributions.inject(0) { |sum, c| sum + c.net_value } - platform_fee
  end

  def platform_fee
    pledged * Configuration[:platform_fee].to_f
  end

  def pledged
    contributions.sum(:value)
  end

  def progress
    pledged / project.goal * 100
  end

  def total_contributions
    contributions.length
  end

  def total_contributions_without_matches
    contributions.where(matching_id: nil).length
  end

  def total_payment_service_fee
    contributions.inject(0) { |sum, c| sum + c.payment_service_fee }
  end
end
