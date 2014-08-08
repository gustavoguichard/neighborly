class Project      < ActiveRecord::Base; end
class ProjectTotal < ActiveRecord::Base; end

class CreateProjectTotals < ActiveRecord::Migration
  def change
    create_table :project_totals do |t|
      t.references :project, index: true
      t.decimal :net_amount, default: 0
      t.decimal :platform_fee, default: 0
      t.decimal :pledged, default: 0
      t.integer :progress, default: 0
      t.integer :total_contributions, default: 0
      t.integer :total_contributions_without_matches, default: 0
      t.decimal :total_payment_service_fee, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        create_project_total_for_existing_projects
      end
    end
  end

  def create_project_total_for_existing_projects
    projects_without_project_total = Project.includes(:project_total).
      where(project_totals: { id: nil })

    projects_without_project_total.each do |project|
      Rails.logger.info "Creating ProjectTotal for project ##{project.id}."
      ProjectTotalBuilder.new(project).perform
    end
  end
end
