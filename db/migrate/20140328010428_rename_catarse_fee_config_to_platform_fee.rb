class RenameCatarseFeeConfigToPlatformFee < ActiveRecord::Migration
  def change
    sql = ->(platform_name) do
      <<-SQL
        DROP VIEW contribution_reports_for_project_owners;
        CREATE OR REPLACE VIEW contribution_reports_for_project_owners AS
          SELECT b.project_id, COALESCE(r.id, 0) AS reward_id, r.description AS reward_description, to_char(r.minimum_value, 'FM999999999'::text) AS reward_minimum_value, to_char(b.created_at, 'HH12:MIam DD Mon YY'::text) AS created_at, to_char(b.confirmed_at, 'HH12:MIam DD Mon YY'::text) AS confirmed_at, to_char(b.value, 'FM999999999'::text) AS contribution_value, to_char((b.value * (SELECT (configurations.value)::numeric AS value FROM configurations WHERE (configurations.name = '#{platform_name}_fee'::text))), 'FM999999999.00'::text) AS service_fee, u.email AS user_email, u.name AS user_name, b.payer_email, b.payment_method, COALESCE(b.address_street, u.address_street) AS street, COALESCE(b.address_complement, u.address_complement) AS complement, COALESCE(b.address_number, u.address_number) AS address_number, COALESCE(b.address_neighborhood, u.address_neighborhood) AS neighborhood, COALESCE(b.address_city, u.address_city) AS city, COALESCE(b.address_state, u.address_state) AS state, COALESCE(b.address_zip_code, u.address_zip_code) AS zip_code, b.anonymous, b.short_note FROM ((contributions b JOIN users u ON ((u.id = b.user_id))) LEFT JOIN rewards r ON ((r.id = b.reward_id))) WHERE ((b.state)::text = 'confirmed'::text) ORDER BY b.confirmed_at, b.id;

        DROP VIEW project_financials;
        CREATE OR REPLACE VIEW project_financials AS
          WITH #{platform_name}_fee_percentage AS (SELECT (c.value)::numeric AS total, ((1)::numeric - (c.value)::numeric) AS complement FROM configurations c WHERE (c.name = '#{platform_name}_fee'::text)), #{platform_name}_base_url AS (SELECT c.value FROM configurations c WHERE (c.name = 'base_url'::text)) SELECT p.id AS project_id, p.name, u.moip_login AS moip, p.goal, pt.pledged AS reached, pt.total_payment_service_fee AS moip_tax, (cp.total * pt.pledged) AS #{platform_name}_fee, (pt.pledged * cp.complement) AS repass_value, to_char(expires_at(p.*), 'dd/mm/yyyy'::text) AS expires_at, ((#{platform_name}_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report, p.state FROM ((((projects p JOIN users u ON ((u.id = p.user_id))) JOIN project_totals pt ON ((pt.project_id = p.id))) CROSS JOIN #{platform_name}_fee_percentage cp) CROSS JOIN #{platform_name}_base_url);
      SQL
    end

    reversible do |direction|
      direction.up   { execute sql.call('platform') }
      direction.down { execute sql.call('catarse') }
    end
  end
end
