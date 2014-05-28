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
         ORDER BY random() LIMIT 4) (((
                                        (SELECT *
                                         FROM featured_projects
                                         UNION SELECT *
                                         FROM recommended_projects)
                                      UNION
                                      SELECT *
                                      FROM expiring_projects)
                                     UNION
                                     SELECT *
                                     FROM soon_projects)
                                      UNION
                                     SELECT *
                                     FROM with_active_matches)
      UNION
      SELECT *
      FROM successful_projects;
    SQL
  end

  def down
    drop_view :projects_for_home

    execute <<-SQL
      CREATE VIEW projects_for_home AS WITH featured_projects AS
        (SELECT 'featured'::text AS origin,
                featureds.id,
                featureds.name,
                featureds.user_id,
                featureds.category_id,
                featureds.goal,
                featureds.about,
                featureds.headline,
                featureds.video_url,
                featureds.short_url,
                featureds.created_at,
                featureds.updated_at,
                featureds.about_html,
                featureds.recommended,
                featureds.home_page_comment,
                featureds.permalink,
                featureds.video_thumbnail,
                featureds.state,
                featureds.online_days,
                featureds.online_date,
                featureds.how_know,
                featureds.more_links,
                featureds.first_contributions,
                featureds.uploaded_image,
                featureds.video_embed_url,
                featureds.budget,
                featureds.budget_html,
                featureds.terms,
                featureds.terms_html,
                featureds.site,
                featureds.hash_tag,
                featureds.address_city,
                featureds.address_state,
                featureds.address_zip_code,
                featureds.address_neighborhood,
                featureds.foundation_widget,
                featureds.campaign_type,
                featureds.featured,
                featureds.home_page,
                featureds.about_textile,
                featureds.budget_textile,
                featureds.terms_textile,
                featureds.latitude,
                featureds.longitude,
                featureds.referal_link,
                featureds.hero_image,
                featureds.sent_to_analysis_at,
                featureds.organization_type,
                featureds.street_address
         FROM projects featureds
         WHERE (featureds.featured
                AND ((featureds.state)::text = 'online'::text)) LIMIT 1),
                  recommended_projects AS
        (SELECT 'recommended'::text AS origin,
                recommends.id,
                recommends.name,
                recommends.user_id,
                recommends.category_id,
                recommends.goal,
                recommends.about,
                recommends.headline,
                recommends.video_url,
                recommends.short_url,
                recommends.created_at,
                recommends.updated_at,
                recommends.about_html,
                recommends.recommended,
                recommends.home_page_comment,
                recommends.permalink,
                recommends.video_thumbnail,
                recommends.state,
                recommends.online_days,
                recommends.online_date,
                recommends.how_know,
                recommends.more_links,
                recommends.first_contributions,
                recommends.uploaded_image,
                recommends.video_embed_url,
                recommends.budget,
                recommends.budget_html,
                recommends.terms,
                recommends.terms_html,
                recommends.site,
                recommends.hash_tag,
                recommends.address_city,
                recommends.address_state,
                recommends.address_zip_code,
                recommends.address_neighborhood,
                recommends.foundation_widget,
                recommends.campaign_type,
                recommends.featured,
                recommends.home_page,
                recommends.about_textile,
                recommends.budget_textile,
                recommends.terms_textile,
                recommends.latitude,
                recommends.longitude,
                recommends.referal_link,
                recommends.hero_image,
                recommends.sent_to_analysis_at,
                recommends.organization_type,
                recommends.street_address
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
                expiring.id,
                expiring.name,
                expiring.user_id,
                expiring.category_id,
                expiring.goal,
                expiring.about,
                expiring.headline,
                expiring.video_url,
                expiring.short_url,
                expiring.created_at,
                expiring.updated_at,
                expiring.about_html,
                expiring.recommended,
                expiring.home_page_comment,
                expiring.permalink,
                expiring.video_thumbnail,
                expiring.state,
                expiring.online_days,
                expiring.online_date,
                expiring.how_know,
                expiring.more_links,
                expiring.first_contributions,
                expiring.uploaded_image,
                expiring.video_embed_url,
                expiring.budget,
                expiring.budget_html,
                expiring.terms,
                expiring.terms_html,
                expiring.site,
                expiring.hash_tag,
                expiring.address_city,
                expiring.address_state,
                expiring.address_zip_code,
                expiring.address_neighborhood,
                expiring.foundation_widget,
                expiring.campaign_type,
                expiring.featured,
                expiring.home_page,
                expiring.about_textile,
                expiring.budget_textile,
                expiring.terms_textile,
                expiring.latitude,
                expiring.longitude,
                expiring.referal_link,
                expiring.hero_image,
                expiring.sent_to_analysis_at,
                expiring.organization_type,
                expiring.street_address
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
                soon.id,
                soon.name,
                soon.user_id,
                soon.category_id,
                soon.goal,
                soon.about,
                soon.headline,
                soon.video_url,
                soon.short_url,
                soon.created_at,
                soon.updated_at,
                soon.about_html,
                soon.recommended,
                soon.home_page_comment,
                soon.permalink,
                soon.video_thumbnail,
                soon.state,
                soon.online_days,
                soon.online_date,
                soon.how_know,
                soon.more_links,
                soon.first_contributions,
                soon.uploaded_image,
                soon.video_embed_url,
                soon.budget,
                soon.budget_html,
                soon.terms,
                soon.terms_html,
                soon.site,
                soon.hash_tag,
                soon.address_city,
                soon.address_state,
                soon.address_zip_code,
                soon.address_neighborhood,
                soon.foundation_widget,
                soon.campaign_type,
                soon.featured,
                soon.home_page,
                soon.about_textile,
                soon.budget_textile,
                soon.terms_textile,
                soon.latitude,
                soon.longitude,
                soon.referal_link,
                soon.hero_image,
                soon.sent_to_analysis_at,
                soon.organization_type,
                soon.street_address
         FROM projects soon
         WHERE ((((soon.state)::text = 'soon'::text)
                 AND soon.home_page)
                AND (soon.uploaded_image IS NOT NULL))
         ORDER BY random() LIMIT 4),
                  successful_projects AS
        (SELECT 'successful'::text AS origin,
                successful.id,
                successful.name,
                successful.user_id,
                successful.category_id,
                successful.goal,
                successful.about,
                successful.headline,
                successful.video_url,
                successful.short_url,
                successful.created_at,
                successful.updated_at,
                successful.about_html,
                successful.recommended,
                successful.home_page_comment,
                successful.permalink,
                successful.video_thumbnail,
                successful.state,
                successful.online_days,
                successful.online_date,
                successful.how_know,
                successful.more_links,
                successful.first_contributions,
                successful.uploaded_image,
                successful.video_embed_url,
                successful.budget,
                successful.budget_html,
                successful.terms,
                successful.terms_html,
                successful.site,
                successful.hash_tag,
                successful.address_city,
                successful.address_state,
                successful.address_zip_code,
                successful.address_neighborhood,
                successful.foundation_widget,
                successful.campaign_type,
                successful.featured,
                successful.home_page,
                successful.about_textile,
                successful.budget_textile,
                successful.terms_textile,
                successful.latitude,
                successful.longitude,
                successful.referal_link,
                successful.hero_image,
                successful.sent_to_analysis_at,
                successful.organization_type,
                successful.street_address
         FROM projects successful
         WHERE (((successful.state)::text = 'successful'::text)
                AND successful.home_page)
         ORDER BY random() LIMIT 4) ((
                                        (SELECT featured_projects.origin,
                                                featured_projects.id,
                                                featured_projects.name,
                                                featured_projects.user_id,
                                                featured_projects.category_id,
                                                featured_projects.goal,
                                                featured_projects.about,
                                                featured_projects.headline,
                                                featured_projects.video_url,
                                                featured_projects.short_url,
                                                featured_projects.created_at,
                                                featured_projects.updated_at,
                                                featured_projects.about_html,
                                                featured_projects.recommended,
                                                featured_projects.home_page_comment,
                                                featured_projects.permalink,
                                                featured_projects.video_thumbnail,
                                                featured_projects.state,
                                                featured_projects.online_days,
                                                featured_projects.online_date,
                                                featured_projects.how_know,
                                                featured_projects.more_links,
                                                featured_projects.first_contributions,
                                                featured_projects.uploaded_image,
                                                featured_projects.video_embed_url,
                                                featured_projects.budget,
                                                featured_projects.budget_html,
                                                featured_projects.terms,
                                                featured_projects.terms_html,
                                                featured_projects.site,
                                                featured_projects.hash_tag,
                                                featured_projects.address_city,
                                                featured_projects.address_state,
                                                featured_projects.address_zip_code,
                                                featured_projects.address_neighborhood,
                                                featured_projects.foundation_widget,
                                                featured_projects.campaign_type,
                                                featured_projects.featured,
                                                featured_projects.home_page,
                                                featured_projects.about_textile,
                                                featured_projects.budget_textile,
                                                featured_projects.terms_textile,
                                                featured_projects.latitude,
                                                featured_projects.longitude,
                                                featured_projects.referal_link,
                                                featured_projects.hero_image,
                                                featured_projects.sent_to_analysis_at,
                                                featured_projects.organization_type,
                                                featured_projects.street_address
                                         FROM featured_projects
                                         UNION SELECT recommended_projects.origin,
                                                      recommended_projects.id,
                                                      recommended_projects.name,
                                                      recommended_projects.user_id,
                                                      recommended_projects.category_id,
                                                      recommended_projects.goal,
                                                      recommended_projects.about,
                                                      recommended_projects.headline,
                                                      recommended_projects.video_url,
                                                      recommended_projects.short_url,
                                                      recommended_projects.created_at,
                                                      recommended_projects.updated_at,
                                                      recommended_projects.about_html,
                                                      recommended_projects.recommended,
                                                      recommended_projects.home_page_comment,
                                                      recommended_projects.permalink,
                                                      recommended_projects.video_thumbnail,
                                                      recommended_projects.state,
                                                      recommended_projects.online_days,
                                                      recommended_projects.online_date,
                                                      recommended_projects.how_know,
                                                      recommended_projects.more_links,
                                                      recommended_projects.first_contributions,
                                                      recommended_projects.uploaded_image,
                                                      recommended_projects.video_embed_url,
                                                      recommended_projects.budget,
                                                      recommended_projects.budget_html,
                                                      recommended_projects.terms,
                                                      recommended_projects.terms_html,
                                                      recommended_projects.site,
                                                      recommended_projects.hash_tag,
                                                      recommended_projects.address_city,
                                                      recommended_projects.address_state,
                                                      recommended_projects.address_zip_code,
                                                      recommended_projects.address_neighborhood,
                                                      recommended_projects.foundation_widget,
                                                      recommended_projects.campaign_type,
                                                      recommended_projects.featured,
                                                      recommended_projects.home_page,
                                                      recommended_projects.about_textile,
                                                      recommended_projects.budget_textile,
                                                      recommended_projects.terms_textile,
                                                      recommended_projects.latitude,
                                                      recommended_projects.longitude,
                                                      recommended_projects.referal_link,
                                                      recommended_projects.hero_image,
                                                      recommended_projects.sent_to_analysis_at,
                                                      recommended_projects.organization_type,
                                                      recommended_projects.street_address
                                         FROM recommended_projects)
                                      UNION
                                      SELECT expiring_projects.origin,
                                             expiring_projects.id,
                                             expiring_projects.name,
                                             expiring_projects.user_id,
                                             expiring_projects.category_id,
                                             expiring_projects.goal,
                                             expiring_projects.about,
                                             expiring_projects.headline,
                                             expiring_projects.video_url,
                                             expiring_projects.short_url,
                                             expiring_projects.created_at,
                                             expiring_projects.updated_at,
                                             expiring_projects.about_html,
                                             expiring_projects.recommended,
                                             expiring_projects.home_page_comment,
                                             expiring_projects.permalink,
                                             expiring_projects.video_thumbnail,
                                             expiring_projects.state,
                                             expiring_projects.online_days,
                                             expiring_projects.online_date,
                                             expiring_projects.how_know,
                                             expiring_projects.more_links,
                                             expiring_projects.first_contributions,
                                             expiring_projects.uploaded_image,
                                             expiring_projects.video_embed_url,
                                             expiring_projects.budget,
                                             expiring_projects.budget_html,
                                             expiring_projects.terms,
                                             expiring_projects.terms_html,
                                             expiring_projects.site,
                                             expiring_projects.hash_tag,
                                             expiring_projects.address_city,
                                             expiring_projects.address_state,
                                             expiring_projects.address_zip_code,
                                             expiring_projects.address_neighborhood,
                                             expiring_projects.foundation_widget,
                                             expiring_projects.campaign_type,
                                             expiring_projects.featured,
                                             expiring_projects.home_page,
                                             expiring_projects.about_textile,
                                             expiring_projects.budget_textile,
                                             expiring_projects.terms_textile,
                                             expiring_projects.latitude,
                                             expiring_projects.longitude,
                                             expiring_projects.referal_link,
                                             expiring_projects.hero_image,
                                             expiring_projects.sent_to_analysis_at,
                                             expiring_projects.organization_type,
                                             expiring_projects.street_address
                                      FROM expiring_projects)
                                     UNION
                                     SELECT soon_projects.origin,
                                            soon_projects.id,
                                            soon_projects.name,
                                            soon_projects.user_id,
                                            soon_projects.category_id,
                                            soon_projects.goal,
                                            soon_projects.about,
                                            soon_projects.headline,
                                            soon_projects.video_url,
                                            soon_projects.short_url,
                                            soon_projects.created_at,
                                            soon_projects.updated_at,
                                            soon_projects.about_html,
                                            soon_projects.recommended,
                                            soon_projects.home_page_comment,
                                            soon_projects.permalink,
                                            soon_projects.video_thumbnail,
                                            soon_projects.state,
                                            soon_projects.online_days,
                                            soon_projects.online_date,
                                            soon_projects.how_know,
                                            soon_projects.more_links,
                                            soon_projects.first_contributions,
                                            soon_projects.uploaded_image,
                                            soon_projects.video_embed_url,
                                            soon_projects.budget,
                                            soon_projects.budget_html,
                                            soon_projects.terms,
                                            soon_projects.terms_html,
                                            soon_projects.site,
                                            soon_projects.hash_tag,
                                            soon_projects.address_city,
                                            soon_projects.address_state,
                                            soon_projects.address_zip_code,
                                            soon_projects.address_neighborhood,
                                            soon_projects.foundation_widget,
                                            soon_projects.campaign_type,
                                            soon_projects.featured,
                                            soon_projects.home_page,
                                            soon_projects.about_textile,
                                            soon_projects.budget_textile,
                                            soon_projects.terms_textile,
                                            soon_projects.latitude,
                                            soon_projects.longitude,
                                            soon_projects.referal_link,
                                            soon_projects.hero_image,
                                            soon_projects.sent_to_analysis_at,
                                            soon_projects.organization_type,
                                            soon_projects.street_address
                                     FROM soon_projects)
      UNION
      SELECT successful_projects.origin,
             successful_projects.id,
             successful_projects.name,
             successful_projects.user_id,
             successful_projects.category_id,
             successful_projects.goal,
             successful_projects.about,
             successful_projects.headline,
             successful_projects.video_url,
             successful_projects.short_url,
             successful_projects.created_at,
             successful_projects.updated_at,
             successful_projects.about_html,
             successful_projects.recommended,
             successful_projects.home_page_comment,
             successful_projects.permalink,
             successful_projects.video_thumbnail,
             successful_projects.state,
             successful_projects.online_days,
             successful_projects.online_date,
             successful_projects.how_know,
             successful_projects.more_links,
             successful_projects.first_contributions,
             successful_projects.uploaded_image,
             successful_projects.video_embed_url,
             successful_projects.budget,
             successful_projects.budget_html,
             successful_projects.terms,
             successful_projects.terms_html,
             successful_projects.site,
             successful_projects.hash_tag,
             successful_projects.address_city,
             successful_projects.address_state,
             successful_projects.address_zip_code,
             successful_projects.address_neighborhood,
             successful_projects.foundation_widget,
             successful_projects.campaign_type,
             successful_projects.featured,
             successful_projects.home_page,
             successful_projects.about_textile,
             successful_projects.budget_textile,
             successful_projects.terms_textile,
             successful_projects.latitude,
             successful_projects.longitude,
             successful_projects.referal_link,
             successful_projects.hero_image,
             successful_projects.sent_to_analysis_at,
             successful_projects.organization_type,
             successful_projects.street_address
      FROM successful_projects;
    SQL
  end
end
