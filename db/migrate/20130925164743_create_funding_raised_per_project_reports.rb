class CreateFundingRaisedPerProjectReports < ActiveRecord::Migration
  def up
    execute <<-SQL
        CREATE OR REPLACE VIEW funding_raised_per_project_reports AS
        SELECT
          project.id AS project_id,
          project.name AS project_name,
          sum(backers.value) AS total_raised,
          count(*) AS total_backs,
          count(DISTINCT backers.user_id) AS total_backers
         FROM backers
         JOIN projects AS project ON project.id = backers.project_id
        WHERE backers.state::text <> ALL (ARRAY['waiting_confirmation'::character varying::text, 'pending'::character varying::text, 'canceled'::character varying::text, 'deleted'])
        GROUP BY project.id;
    SQL
  end

  def down
    drop_view :funding_raised_per_project_report
  end
end
