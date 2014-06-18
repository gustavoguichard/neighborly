class RemoveConfigurations < ActiveRecord::Migration
  def up
    drop_view :contribution_reports_for_project_owners
    drop_view :project_financials_by_services
    drop_view :project_financials
    drop_view :project_totals
    drop_view :contribution_reports
    drop_view :contributions_fees
    drop_view :projects_for_home
    drop_table :configurations
    execute <<-SQL
      DROP FUNCTION expires_at(projects);

      CREATE FUNCTION expires_at(projects) RETURNS timestamp with time zone
        LANGUAGE sql
        AS $_$
         SELECT ((($1.online_date AT TIME ZONE '#{Configuration[:timezone]}' + ($1.online_days || ' days')::interval)::date::text || ' 23:59:59')::timestamp AT TIME ZONE '#{Configuration[:timezone]}')
        $_$
    SQL

    create_projects_for_home_view
  end

  def down
    create_table :configurations do |t|
      t.text :name, null: false
      t.text :value
    end

    drop_view :projects_for_home

    execute <<-SQL
      DROP FUNCTION expires_at(projects);

      CREATE FUNCTION expires_at(projects) RETURNS timestamp with time zone
        LANGUAGE sql
        AS $_$
         SELECT ((((($1.online_date AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo') + ($1.online_days || ' days')::interval)  )::date::text || ' 23:59:59')::timestamp AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo'))::timestamptz )               
        $_$
    SQL

    create_projects_for_home_view

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
             sum(contributions_fees.payment_service_fee) AS total_payment_service_fee,
             count(*) AS total_contributions,
             (sum(contributions.value) *
                (SELECT (configurations.value)::numeric AS value
                 FROM configurations
                 WHERE (configurations.name = 'platform_fee'::text))) AS platform_fee,
             (sum(contributions_fees.net_payment) - (sum(contributions.value) *
                                                      (SELECT (configurations.value)::numeric AS value
                                                       FROM configurations
                                                       WHERE (configurations.name = 'platform_fee'::text)))) AS net_amount
      FROM ((contributions
             JOIN projects ON ((contributions.project_id = projects.id)))
            JOIN contributions_fees ON ((contributions_fees.id = contributions.id)))
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
             (contributions_fees.net_payment - (sum(contributions.value) *
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
            JOIN contributions_fees ON ((contributions.id = contributions_fees.id)))
      WHERE ((contributions.state)::text = 'confirmed'::text)
      GROUP BY contributions.project_id,
               contributions.payment_method,
               contributions_fees.net_payment HAVING (contributions.payment_method IS NOT NULL)
    SQL

    create_view :contribution_reports, <<-SQL
      SELECT b.project_id,
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
FROM (((contributions b
        JOIN users u ON ((u.id = b.user_id)))
       LEFT JOIN rewards r ON ((r.id = b.reward_id)))
      JOIN contributions_fees fees ON ((fees.id = b.id)))
WHERE ((b.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]))
    SQL
  end

  def create_projects_for_home_view
    execute <<-SQL
      CREATE VIEW projects_for_home AS WITH featured_projects AS
        (SELECT 'featured'::text AS origin,
                featureds.*
         FROM projects featureds
         WHERE (featureds.featured
                AND ((featureds.state)::text = 'online'::text)) LIMIT 1),
                  recommended_projects AS
        (SELECT 'recommended'::text AS origin,
                recommends.*
         FROM projects recommends
         WHERE (((recommends.recommended
                  AND ((recommends.state)::text = 'online'::text))
                 AND recommends.home_page)
                AND (NOT (recommends.id IN
                            (SELECT featureds.id
                             FROM featured_projects featureds))))
         ORDER BY random() LIMIT 5),
                  expiring_projects AS
        (SELECT 'expiring'::text AS origin,
                expiring.*
         FROM projects expiring
         WHERE (((((expiring.state)::text = 'online'::text)
                  AND (expires_at(expiring.*) <= (now() + '14 days'::interval)))
                 AND expiring.home_page)
                AND (NOT (expiring.id IN
                            (SELECT recommends.id
                             FROM recommended_projects recommends
                             UNION SELECT featureds.id
                             FROM featured_projects featureds))))
         ORDER BY random() LIMIT 4),
                  soon_projects AS
        (SELECT 'soon'::text AS origin,
                soon.*
         FROM projects soon
         WHERE ((((soon.state)::text = 'soon'::text)
                 AND soon.home_page)
                AND (soon.uploaded_image IS NOT NULL))
         ORDER BY random() LIMIT 4),
                  with_active_matches AS
        (SELECT 'with_active_matches'::text AS origin,
               with_active_matches.*
        FROM projects with_active_matches
        LEFT OUTER JOIN matches ON matches.project_id = with_active_matches.id
        WHERE matches.id IN
            (SELECT matches.id
             FROM matches
             WHERE (matches.state = 'confirmed')
               AND (starts_at <= now()::date
                    AND finishes_at >= now()::date))
        ORDER BY random() LIMIT 4),
                  successful_projects AS
        (SELECT 'successful'::text AS origin,
                successful.*
         FROM projects successful
         WHERE (((successful.state)::text = 'successful'::text)
                AND successful.home_page)
         ORDER BY random() LIMIT 4)
         (SELECT * from featured_projects) UNION
         (SELECT * from recommended_projects) UNION
         (SELECT * from expiring_projects) UNION
         (SELECT * from soon_projects) UNION
         (SELECT * from with_active_matches) UNION
         (SELECT * from successful_projects)
    SQL
  end
end
