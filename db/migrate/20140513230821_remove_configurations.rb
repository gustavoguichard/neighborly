class RemoveConfigurations < ActiveRecord::Migration
  def up
    drop_view :contribution_reports_for_project_owners
    drop_view :project_financials_by_services
    drop_view :project_financials
    drop_view :project_totals
    drop_table :configurations
  end

  def down
    drop_view :contribution_reports_for_project_owners
    drop_view :project_financials_by_services
    drop_view :project_financials
    drop_view :project_totals

    create_table :configurations do |t|
      t.text :name, null: false
      t.text :value
    end

    create_view :contribution_reports_for_project_owners, <<-SQL
      SELECT b.project_id,
             COALESCE(r.id, 0) AS reward_id,
             r.description AS reward_description,
             to_char(r.minimum_value, 'FM999999999'::text) AS reward_minimum_value,
             to_char(b.created_at, 'HH12:MIam DD Mon YY'::text) AS created_at,
             to_char(b.confirmed_at, 'HH12:MIam DD Mon YY'::text) AS confirmed_at,
             to_char(b.value, 'FM999999999'::text) AS contribution_value,
             to_char((b.value *
                        (SELECT (configurations.value)::numeric AS value
                         FROM configurations
                         WHERE (configurations.name = 'platform_fee'::text))), 'FM999999999.00'::text) AS service_fee,
             u.email AS user_email,
             u.name AS user_name,
             b.payer_email,
             b.payment_method,
             COALESCE(b.address_street, u.address_street) AS street,
             COALESCE(b.address_complement, u.address_complement) AS complement,
             COALESCE(b.address_number, u.address_number) AS address_number,
             COALESCE(b.address_neighborhood, u.address_neighborhood) AS neighborhood,
             COALESCE(b.address_city, u.address_city) AS city,
             COALESCE(b.address_state, u.address_state) AS STATE,
             COALESCE(b.address_zip_code, u.address_zip_code) AS zip_code,
             b.anonymous,
             b.short_note
      FROM ((contributions b
             JOIN users u ON ((u.id = b.user_id)))
            LEFT JOIN rewards r ON ((r.id = b.reward_id)))
      WHERE ((b.STATE)::text = 'confirmed'::text)
      ORDER BY b.confirmed_at,
               b.id
    SQL

    create_view :project_totals, <<-SQL
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
    SQL

    execute <<-SQL
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
    SQL

    create_view :project_financials_by_services, <<-SQL
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
    SQL
  end
end
