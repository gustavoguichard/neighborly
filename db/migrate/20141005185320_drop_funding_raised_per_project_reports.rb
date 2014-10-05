class DropFundingRaisedPerProjectReports < ActiveRecord::Migration
  def uo
    drop_view :funding_raised_per_project_reports
  end

  def down
    execute <<-SQL
        CREATE OR REPLACE VIEW funding_raised_per_project_reports AS
        SELECT
          project.id AS project_id,
          project.name AS project_name,
          sum(contributions.value) AS total_raised,
          count(*) AS total_backs,
          count(DISTINCT contributions.user_id) AS total_backers
         FROM contributions
         JOIN projects AS project ON project.id = contributions.project_id
        WHERE contributions.state::text <> ALL (ARRAY['waiting_confirmation'::character varying::text, 'pending'::character varying::text, 'canceled'::character varying::text, 'deleted'])
        GROUP BY project.id;
    SQL
  end
end
