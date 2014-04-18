class CreateProjectFinancialsByServices < ActiveRecord::Migration
  def up
    execute "
      CREATE OR REPLACE VIEW project_financials_by_services AS
      SELECT contributions.project_id,
             contributions.payment_method AS payment_method,
             sum(contributions.value - (CASE WHEN payment_service_fee_paid_by_user then 0 else contributions.payment_service_fee end)) * (1 - (SELECT value::numeric FROM configurations WHERE name = 'platform_fee')) AS net_amount,
             sum(contributions.value) * (SELECT value::numeric FROM configurations WHERE name = 'platform_fee') AS platform_fee,
             sum(contributions.payment_service_fee) AS payment_service_fee,
             count(*) AS total_contributions
      FROM (contributions JOIN projects ON (contributions.project_id = projects.id))
      WHERE contributions.state = 'confirmed'
      GROUP BY contributions.project_id, contributions.payment_method
      HAVING contributions.payment_method IS NOT NULL;"
  end

  def down
    execute "DROP VIEW project_financials_by_services;"
  end
end
