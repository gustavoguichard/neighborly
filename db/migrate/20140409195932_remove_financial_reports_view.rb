class RemoveFinancialReportsView < ActiveRecord::Migration
  def up
    execute 'DROP VIEW financial_reports;'
  end

  def down
    execute <<-SQL
      CREATE VIEW financial_reports AS
SELECT p.name, u.moip_login, p.goal, expires_at(p.*) AS expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));
      SQL
  end
end
