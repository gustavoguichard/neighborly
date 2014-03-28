class MigrateProjectsForHomeToNeighborly < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW projects_for_home;
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

  def down
    execute <<-SQL
      DROP VIEW projects_for_home;
      CREATE OR REPLACE VIEW projects_for_home AS
        with recommended_projects as (
          select 'recommended'::text as origin, recommends.* from projects recommends
          where recommends.recommended and recommends.state = 'online' order by random() limit 3
        ),
        recents_projects as (
          select 'recents'::text as origin, recents.* from projects recents
          where recents.state = 'online'
          and ((current_timestamp - recents.online_date) <= '5 days'::interval)
          and recents.id not in(
            select recommends.id from recommended_projects recommends
          )
          order by random() limit 3
        ),
        expiring_projects as (
          select 'expiring'::text as origin, expiring.* from projects expiring
          where expiring.state = 'online'
          and ((expiring.expires_at) <= ((current_timestamp) + interval '2 weeks'))
          and expiring.id not in(
            (select recommends.id from recommended_projects recommends)
            union (select recents.id from recents_projects recents)
          )
          order by random() limit 3
        )

        (select * from recommended_projects) union (select * from recents_projects) union (select * from expiring_projects)

    SQL
  end
end
