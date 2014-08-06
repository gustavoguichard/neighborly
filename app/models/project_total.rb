class ProjectTotal
  attr_accessor :project

  def initialize(project)
    @project = project
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
    pledged / projects.goal * 100
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

  private

  def contributions
    project.contributions.with_state(:confirmed, :refunded, :requested_refund)
  end
end
