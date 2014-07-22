class RemoveActiveMatchesFromHome < ActiveRecord::Migration
  def up
    drop_view :projects_for_home

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
         (SELECT * from successful_projects)
    SQL
  end

  def down
    drop_view :projects_for_home

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
