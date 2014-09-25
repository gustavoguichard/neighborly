class RemoveFoundationWidgetFromProjects < ActiveRecord::Migration
  def change
    drop_dependent_objects
    remove_column :projects, :foundation_widget, :string
    create_dependent_objects
  end

  def drop_dependent_objects
    drop_view :projects_for_home
  end

  def create_dependent_objects
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
end
