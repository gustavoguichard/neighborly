class DropUserTotalsView < ActiveRecord::Migration
  def up
    drop_view :user_totals
  end

  def down
    execute <<-SQL
      CREATE VIEW user_totals AS
       SELECT b.user_id AS id,
          b.user_id,
          count(DISTINCT b.project_id) AS total_contributed_projects,
          sum(b.value) AS sum,
          count(*) AS count,
          sum(
              CASE
                  WHEN (((p.state)::text <> 'failed'::text) AND (NOT b.credits)) THEN (0)::numeric
                  WHEN (((p.state)::text = 'failed'::text) AND b.credits) THEN (0)::numeric
                  WHEN (((p.state)::text = 'failed'::text) AND ((((b.state)::text = ANY ((ARRAY['requested_refund'::character varying, 'refunded'::character varying])::text[])) AND (NOT b.credits)) OR (b.credits AND (NOT ((b.state)::text = ANY ((ARRAY['requested_refund'::character varying, 'refunded'::character varying])::text[])))))) THEN (0)::numeric
                  WHEN ((((p.state)::text = 'failed'::text) AND (NOT b.credits)) AND ((b.state)::text = 'confirmed'::text)) THEN b.value
                  ELSE (b.value * ((-1))::numeric)
              END) AS credits
         FROM (contributions b
           JOIN projects p ON ((b.project_id = p.id)))
        WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'requested_refund'::character varying, 'refunded'::character varying])::text[]))
        GROUP BY b.user_id;
    SQL
  end
end
