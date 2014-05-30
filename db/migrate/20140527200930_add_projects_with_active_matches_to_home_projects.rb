class AddProjectsWithActiveMatchesToHomeProjects < ActiveRecord::Migration
  def up
    drop_view :projects_for_home

    # Removes field list on each SELECT of projects_for_home
    # Adds search for projects with active matches
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

  def down
    drop_view :projects_for_home

    execute <<-SQL
      CREATE OR REPLACE VIEW projects_for_home AS
        with featured_projects as (
          select 'featured'::text as origin, featureds.* from projects featureds
          where featureds.featured
          and featureds.state = 'online'
          limit 1
        ),
        recommended_projects as (
          select 'recommended'::text as origin, recommends.* from projects recommends
          where recommends.recommended
          and recommends.state = 'online'
          and recommends.home_page
          and recommends.id not in(
            select featureds.id from featured_projects featureds
          )
          order by random() limit 5
        ),
        expiring_projects as (
          select 'expiring'::text as origin, expiring.* from projects expiring
          where expiring.state = 'online'
          and ((expiring.expires_at) <= ((current_timestamp) + interval '2 weeks'))
          and expiring.home_page
          and expiring.id not in(
            (select recommends.id from recommended_projects recommends)
            union (select featureds.id from featured_projects featureds)
          )
          order by random() limit 4
        ),
        soon_projects as (
          select 'soon'::text as origin, soon.* from projects soon
          where soon.state = 'soon'
          and soon.home_page
          order by random() limit 4
        ),
        successful_projects as (
          select 'successful'::text as origin, successful.* from projects successful
          where successful.state = 'successful'
          and successful.home_page
          order by random() limit 4
        )

        (select * from featured_projects) union
        (select * from recommended_projects) union
        (select * from expiring_projects) union
        (select * from soon_projects) union
        (select * from successful_projects)
    SQL
  end
end
