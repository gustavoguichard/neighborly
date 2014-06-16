class ProjectFinancial
=begin
CREATE VIEW project_financials AS WITH platform_fee_percentage AS
  (SELECT (c.value)::numeric AS total,
          ((1)::numeric - (c.value)::numeric) AS complement
   FROM configurations c
   WHERE (c.name = 'platform_fee'::text)),
            platform_base_url AS
  (SELECT c.value
   FROM configurations c
   WHERE (c.name = 'base_url'::text))
SELECT p.id AS project_id,
       p.name,
       u.moip_login AS moip,
       p.goal,
       pt.pledged AS reached,
       pt.total_payment_service_fee AS moip_tax,
       pt.platform_fee,
       pt.net_amount AS repass_value,
       to_char(expires_at(p.*), 'dd/mm/yyyy'::text) AS expires_at,
       ((platform_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report,
       p.state
FROM ((((projects p
         JOIN users u ON ((u.id = p.user_id)))
        JOIN project_totals pt ON ((pt.project_id = p.id)))
       CROSS JOIN platform_fee_percentage cp)
      CROSS JOIN platform_base_url)
=end

  include ActiveModel::Serialization

  attr_accessor :project

  delegate :user, :id, :goal, :name, :state, to: :project
  delegate :platform_fee, to: :project_total

  def initialize(project)
    @project = project
  end

  def attributes
    {
      contribution_report: contribution_report,
      expires_at: expires_at,
      goal: goal,
      moip: moip,
      moip_tax: moip_tax,
      name: name,
      platform_base_url: platform_base_url,
      platform_fee: platform_fee,
      project_id: project_id,
      reached: reached,
      repass_value: repass_value,
      state: state
    }
  end

  def contribution_report
    "#{platform_base_url}/admin/reports/contribution_reports.csv?project_id=#{id}"
  end

  def expires_at
    project.expires_at.to_date
  end

  def moip
    user.moip_login
  end

  def moip_tax
    project_total.total_payment_service_fee
  end

  def platform_base_url
    Configuration[:base_url]
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
