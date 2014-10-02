class RemoveChannels < ActiveRecord::Migration
  def up
    drop_view :subscriber_reports
    drop_table :channels_subscribers
    drop_table :channel_members
    drop_table :channels_projects
    remove_column :notifications, :channel_id, :integer

    drop_view :statistics
    create_view(:statistics,
      "SELECT ( SELECT count(*) AS count
             FROM users) AS total_users,
      ( SELECT count(*) AS count
             FROM users
            WHERE ((users.profile_type)::text = 'organization'::text)) AS total_organization_users,
      ( SELECT count(*) AS count
             FROM users
            WHERE ((users.profile_type)::text = 'personal'::text)) AS total_personal_users,
      ( SELECT count(*) AS count
             FROM ( SELECT DISTINCT projects.address_city,
                      projects.address_state
                     FROM projects) count) AS total_communities,
      contributions_totals.total_contributions,
      contributions_totals.total_contributors,
      contributions_totals.total_contributed,
      projects_totals.total_projects,
      projects_totals.total_projects_success,
      projects_totals.total_projects_online,
      projects_totals.total_projects_draft,
      projects_totals.total_projects_soon
     FROM ( SELECT count(*) AS total_contributions,
              count(DISTINCT contributions.user_id) AS total_contributors,
              sum(contributions.value) AS total_contributed
             FROM contributions
            WHERE ((contributions.state)::text <> ALL (ARRAY[('waiting_confirmation'::character varying)::text, ('pending'::character varying)::text, ('canceled'::character varying)::text, 'deleted'::text]))) contributions_totals,
      ( SELECT count(*) AS total_projects,
              count(
                  CASE
                      WHEN ((projects.state)::text = 'draft'::text) THEN 1
                      ELSE NULL::integer
                  END) AS total_projects_draft,
              count(
                  CASE
                      WHEN ((projects.state)::text = 'soon'::text) THEN 1
                      ELSE NULL::integer
                  END) AS total_projects_soon,
              count(
                  CASE
                      WHEN ((projects.state)::text = 'successful'::text) THEN 1
                      ELSE NULL::integer
                  END) AS total_projects_success,
              count(
                  CASE
                      WHEN ((projects.state)::text = 'online'::text) THEN 1
                      ELSE NULL::integer
                  END) AS total_projects_online
             FROM projects
            WHERE ((projects.state)::text <> ALL (ARRAY[('deleted'::character varying)::text, ('rejected'::character varying)::text]))) projects_totals;

      ")

    drop_table :channels
  end

  def down
    create_table :channels do |t|
      t.string :name, null: false
      t.string :description
      t.string :permalink, index: { unique: true }
      t.text :image
      t.text :video_url
      t.string :video_embed_url
      t.text :how_it_works
      t.text :how_it_works_html
      t.string :terms_url
      t.text :state
      t.integer :user_id
      t.boolean :accepts_projects
      t.text :submit_your_project_text
      t.text :submit_your_project_text_html
      t.hstore :start_content
      t.string :start_hero_image
      t.hstore :success_content
      t.string :application_url

      t.timestamps

    end

    create_table :channels_subscribers do |t|
      t.integer :user_id, null: false
      t.integer :channel_id, null: false
    end

    create_view(:subscriber_reports,
      "SELECT u.id, cs.channel_id, u.name, u.email
        FROM (users u JOIN channels_subscribers cs ON ((cs.user_id = u.id)))"
    )
    create_table :channel_members do |t|
      t.references :channel, index: true
      t.references :user, index: true
      t.boolean :admin, default: false

      t.timestamps
    end

    create_table :channels_projects do |t|
      t.integer :channel_id, index: { with: :project_id, unique: true }
      t.integer :project_id, index: true
    end

    add_column :notifications, :channel_id, :integer

    drop_view :statistics
    create_view(:statistics,
      "SELECT ( SELECT count(*) AS count
                 FROM users) AS total_users,
          ( SELECT count(*) AS count
                 FROM users
                WHERE ((users.profile_type)::text = 'organization'::text)) AS total_organization_users,
          ( SELECT count(*) AS count
                 FROM users
                WHERE ((users.profile_type)::text = 'personal'::text)) AS total_personal_users,
          ( SELECT count(*) AS count
                 FROM users
                WHERE ((users.profile_type)::text = 'channel'::text)) AS total_channel_users,
          ( SELECT count(*) AS count
                 FROM ( SELECT DISTINCT projects.address_city,
                          projects.address_state
                         FROM projects) count) AS total_communities,
          contributions_totals.total_contributions,
          contributions_totals.total_contributors,
          contributions_totals.total_contributed,
          projects_totals.total_projects,
          projects_totals.total_projects_success,
          projects_totals.total_projects_online,
          projects_totals.total_projects_draft,
          projects_totals.total_projects_soon
         FROM ( SELECT count(*) AS total_contributions,
                  count(DISTINCT contributions.user_id) AS total_contributors,
                  sum(contributions.value) AS total_contributed
                 FROM contributions
                WHERE ((contributions.state)::text <> ALL (ARRAY[('waiting_confirmation'::character varying)::text, ('pending'::character varying)::text, ('canceled'::character varying)::text, 'deleted'::text]))) contributions_totals,
          ( SELECT count(*) AS total_projects,
                  count(
                      CASE
                          WHEN ((projects.state)::text = 'draft'::text) THEN 1
                          ELSE NULL::integer
                      END) AS total_projects_draft,
                  count(
                      CASE
                          WHEN ((projects.state)::text = 'soon'::text) THEN 1
                          ELSE NULL::integer
                      END) AS total_projects_soon,
                  count(
                      CASE
                          WHEN ((projects.state)::text = 'successful'::text) THEN 1
                          ELSE NULL::integer
                      END) AS total_projects_success,
                  count(
                      CASE
                          WHEN ((projects.state)::text = 'online'::text) THEN 1
                          ELSE NULL::integer
                      END) AS total_projects_online
                 FROM projects
                WHERE ((projects.state)::text <> ALL (ARRAY[('deleted'::character varying)::text, ('rejected'::character varying)::text]))) projects_totals;
      ")

  end
end
