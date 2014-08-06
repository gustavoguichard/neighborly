class ProjectFinancial
  include ActiveModel::Serialization

  attr_accessor :project

  delegate :user, :id, :goal, :name, :state, to: :project
  delegate :platform_fee, to: :project_total

  def initialize(project)
    @project = project
  end

  def attributes
    {
      project_id:          project_id,
      name:                name,
      goal:                goal,
      reached:             reached,
      service_fee:         service_fee,
      platform_fee:        platform_fee,
      repass_value:        repass_value,
      expires_at:          expires_at,
      contribution_report: contribution_report,
      state:               state
    }
  end

  def contribution_report
    "#{Configuration[:base_url]}/admin/reports/contribution_reports.csv?project_id=#{id}"
  end

  def expires_at
    project.expires_at.to_date
  end

  def service_fee
    project_total.total_payment_service_fee
  end

  def project_id
    project.id
  end

  def reached
    project_total.pledged
  end

  def repass_value
    project_total.net_amount
  end

  private

  def project_total
    @project_total ||= ProjectTotal.new(project)
  end
end
