class ProjectFinancialsByService
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
