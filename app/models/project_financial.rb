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

  delegate :id, :goal, :state, to: :project
  delegate :platform_fee, to: :project_total

  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def contribution_report
    "#{platform_base_url}/admin/reports/contribution_reports.csv?project_id=#{id}"
  end

  def expires_at
    # ???
  end

  def moip
    project.moip_login
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
