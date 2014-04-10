class ImproveOrganizationOfProjectFinancials < ActiveRecord::Migration
  def up
    # Adds platform_fee                to project_totals
    # Adds net_amount                  to project_totals
    # Use  project_totals.platform_fee in project_financials
    # Use  project_totals.net_amount   in project_financials
    execute "
      CREATE OR REPLACE VIEW project_totals AS
      SELECT contributions.project_id,
             SUM(contributions.value) AS pledged,
                ((SUM(contributions.value) / projects.goal) * (100)::numeric) AS progress,
                SUM(contributions.payment_service_fee) AS total_payment_service_fee,
                   count(*) AS total_contributions,
                        (sum(contributions.value) * (SELECT value::numeric FROM configurations WHERE name = 'platform_fee')) AS platform_fee,
                           sum(contributions.value - (CASE WHEN payment_service_fee_paid_by_user then 0 else contributions.payment_service_fee end)) - sum(contributions.value) * (SELECT value::numeric FROM configurations WHERE name = 'platform_fee') AS net_amount
      FROM (contributions
            JOIN projects ON ((contributions.project_id = projects.id)))
      WHERE ((contributions.STATE)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
      GROUP BY contributions.project_id,
               projects.goal;

      CREATE OR REPLACE VIEW project_financials AS WITH platform_fee_percentage AS
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
             pt.platform_fee AS platform_fee,
             pt.net_amount AS repass_value,
             to_char(expires_at(p.*), 'dd/mm/yyyy'::text) AS expires_at,
             ((platform_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report,
             p.STATE
      FROM ((((projects p
               JOIN users u ON ((u.id = p.user_id)))
              JOIN project_totals pt ON ((pt.project_id = p.id)))
             CROSS JOIN platform_fee_percentage cp)
            CROSS JOIN platform_base_url);"
  end

  def down
    execute "
      DROP VIEW project_financials;
      DROP VIEW project_totals;

      CREATE VIEW project_totals AS
      SELECT contributions.project_id,
             SUM(contributions.value) AS pledged,
                ((SUM(contributions.value) / projects.goal) * (100)::numeric) AS progress,
                SUM(contributions.payment_service_fee) AS total_payment_service_fee,
                   count(*) AS total_contributions
      FROM (contributions
            JOIN projects ON ((contributions.project_id = projects.id)))
      WHERE ((contributions.STATE)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
      GROUP BY contributions.project_id,
               projects.goal;

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
             (cp.total * pt.pledged) AS platform_fee,
             (pt.pledged * cp.complement) AS repass_value,
             to_char(expires_at(p.*), 'dd/mm/yyyy'::text) AS expires_at,
             ((platform_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report,
             p.STATE
      FROM ((((projects p
               JOIN users u ON ((u.id = p.user_id)))
              JOIN project_totals pt ON ((pt.project_id = p.id)))
             CROSS JOIN platform_fee_percentage cp)
            CROSS JOIN platform_base_url);"
  end
end
