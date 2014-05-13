class CreateContributionsFeesView < ActiveRecord::Migration
  def up
    drop_view :contribution_reports
    drop_view :project_financials
    drop_view :project_totals
    drop_view :project_financials_by_services

    create_view :contributions_fees, <<-SQL
      SELECT
        contributions.id,
        contributions.value,
        contributions.value -
          (CASE WHEN contributions.payment_service_fee_paid_by_user then
            0
          else
            COALESCE(
              NULLIF(contributions.payment_service_fee, 0),
              matches.payment_service_fee / matches.value * contributions.value,
              0
            )
          end)
          AS net_payment,
        COALESCE(
          NULLIF(contributions.payment_service_fee, 0),
          matches.payment_service_fee / matches.value * contributions.value,
          0
        ) AS payment_service_fee
      FROM contributions
      LEFT JOIN matchings ON contributions.matching_id = matchings.id
      LEFT JOIN matches   ON matchings.match_id        = matches.id
    SQL

    create_view :contribution_reports, <<-SQL
      SELECT
        b.project_id,
        u.name,
        b.value,
        r.minimum_value,
        r.description,
        b.payment_method,
        b.payment_choice,
        fees.payment_service_fee,
        b.key,
        (b.created_at)::date AS created_at,
        (b.confirmed_at)::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        b.payer_document,
        u.address_street,
        u.address_complement,
        u.address_number,
        u.address_neighborhood AS address_neighbourhood,
        u.address_city,
        u.address_state,
        u.address_zip_code,
        b.state
      FROM (
        (contributions b JOIN users u ON (u.id = b.user_id))
        LEFT JOIN rewards r ON (r.id = b.reward_id)
        JOIN contributions_fees fees ON (fees.id = b.id)
      )
      WHERE ((b.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
    SQL

    create_view :project_totals, <<-SQL
      SELECT contributions.project_id,
             sum(contributions.value) AS pledged,
             ((sum(contributions.value) / projects.goal) * (100)::numeric) AS progress,
             sum(contributions_fees.payment_service_fee) AS total_payment_service_fee,
             count(*) AS total_contributions,
             (sum(contributions.value) *
                (SELECT (configurations.value)::numeric AS value
                 FROM configurations
                 WHERE (configurations.name = 'platform_fee'::text))) AS platform_fee,
             (sum(contributions_fees.net_payment) -
              sum(contributions.value) * (SELECT (configurations.value)::numeric AS value
                                          FROM configurations
                                          WHERE (configurations.name = 'platform_fee'::text))) AS net_amount
      FROM (contributions
            JOIN projects ON (contributions.project_id = projects.id)
            JOIN contributions_fees ON (contributions_fees.id = contributions.id))
      WHERE ((contributions.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
      GROUP BY contributions.project_id,
               projects.goal
    SQL

    create_project_financials_view

    create_view :project_financials_by_services, <<-SQL
      SELECT contributions.project_id,
             contributions.payment_method,
             (contributions_fees.net_payment -
              sum(contributions.value) * (SELECT (configurations.value)::numeric AS value
                                           FROM configurations
                                           WHERE (configurations.name = 'platform_fee'::text))) AS net_amount,
             (sum(contributions.value) *
                (SELECT (configurations.value)::numeric AS value
                 FROM configurations
                 WHERE (configurations.name = 'platform_fee'::text))) AS platform_fee,
             sum(contributions.payment_service_fee) AS payment_service_fee,
             count(*) AS total_contributions
      FROM (contributions
            JOIN projects ON (contributions.project_id = projects.id)
            JOIN contributions_fees ON (contributions.id = contributions_fees.id))
      WHERE ((contributions.state)::text = 'confirmed'::text)
      GROUP BY contributions.project_id,
               contributions.payment_method,
               contributions_fees.net_payment
      HAVING (contributions.payment_method IS NOT NULL)
    SQL
  end

  def down
    drop_view :contribution_reports
    drop_view :project_financials_by_services
    drop_view :project_financials
    drop_view :project_totals
    drop_view :contributions_fees

    create_view :contribution_reports, <<-SQL
      SELECT
        b.project_id,
        u.name,
        b.value,
        r.minimum_value,
        r.description,
        b.payment_method,
        b.payment_choice,
        b.payment_service_fee,
        b.key,
        (b.created_at)::date AS created_at,
        (b.confirmed_at)::date AS confirmed_at,
        u.email,
        b.payer_email,
        b.payer_name,
        b.payer_document,
        u.address_street,
        u.address_complement,
        u.address_number,
        u.address_neighborhood AS address_neighbourhood,
        u.address_city,
        u.address_state,
        u.address_zip_code,
        b.state
      FROM (
        (contributions b JOIN users u ON (u.id = b.user_id))
        LEFT JOIN rewards r ON (r.id = b.reward_id)
      )
      WHERE ((b.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
    SQL

    create_view :project_totals, <<-SQL
      SELECT contributions.project_id,
       sum(contributions.value) AS pledged,
       ((sum(contributions.value) / projects.goal) * (100)::numeric) AS progress,
       sum(contributions.payment_service_fee) AS total_payment_service_fee,
       count(*) AS total_contributions,
       (sum(contributions.value) *
          (SELECT (configurations.value)::numeric AS value
           FROM configurations
           WHERE (configurations.name = 'platform_fee'::text))) AS platform_fee,
       (sum((contributions.value - CASE WHEN contributions.payment_service_fee_paid_by_user THEN (0)::numeric ELSE contributions.payment_service_fee END)) - (sum(contributions.value) *
                                                                                                                                                                (SELECT (configurations.value)::numeric AS value
                                                                                                                                                                 FROM configurations
                                                                                                                                                                 WHERE (configurations.name = 'platform_fee'::text)))) AS net_amount
FROM (contributions
      JOIN projects ON ((contributions.project_id = projects.id)))
WHERE ((contributions.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
GROUP BY contributions.project_id,
         projects.goal
    SQL

    create_project_financials_view

    create_view :project_financials_by_services, <<-SQL
      SELECT contributions.project_id,
             contributions.payment_method,
             (sum((contributions.value - CASE WHEN contributions.payment_service_fee_paid_by_user THEN (0)::numeric ELSE contributions.payment_service_fee END)) - (sum(contributions.value) *
                                                                                                                                                                      (SELECT (configurations.value)::numeric AS value
                                                                                                                                                                       FROM configurations
                                                                                                                                                                       WHERE (configurations.name = 'platform_fee'::text)))) AS net_amount,
             (sum(contributions.value) *
                (SELECT (configurations.value)::numeric AS value
                 FROM configurations
                 WHERE (configurations.name = 'platform_fee'::text))) AS platform_fee,
             sum(contributions.payment_service_fee) AS payment_service_fee,
             count(*) AS total_contributions
      FROM (contributions
            JOIN projects ON (contributions.project_id = projects.id))
      WHERE ((contributions.state)::text = 'confirmed'::text)
      GROUP BY contributions.project_id,
               contributions.payment_method
      HAVING (contributions.payment_method IS NOT NULL)
    SQL
  end

  def create_project_financials_view
    execute <<-SQL
      CREATE VIEW project_financials AS
    WITH platform_fee_percentage AS (SELECT (c.value)::numeric AS total, ((1)::numeric - (c.value)::numeric) AS complement FROM configurations c WHERE (c.name = 'platform_fee'::text)), platform_base_url AS (SELECT c.value FROM configurations c WHERE (c.name = 'base_url'::text)) SELECT p.id AS project_id, p.name, u.moip_login AS moip, p.goal, pt.pledged AS reached, pt.total_payment_service_fee AS moip_tax, pt.platform_fee, pt.net_amount AS repass_value, to_char(expires_at(p.*), 'dd/mm/yyyy'::text) AS expires_at, ((platform_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report, p.state FROM ((((projects p JOIN users u ON ((u.id = p.user_id))) JOIN project_totals pt ON ((pt.project_id = p.id))) CROSS JOIN platform_fee_percentage cp) CROSS JOIN platform_base_url)
    SQL
  end
end
