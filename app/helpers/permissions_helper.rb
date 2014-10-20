module PermissionsHelper
  def permissions_discover_attrs
    { 'data-hyperlink-permission' => policy(Project).discover?, 'data-name' => 'Wanted to discover issuances' }
  end

  def permissions_project_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project).partially_show?, 'data-name' => 'Wanted to view issuance' }
  end

  def permissions_new_project_contribution_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project.contributions.new(user: current_user)).create?, 'data-name' => 'Wanted to invest' }
  end

  def permissions_project_contributions_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project.contributions.new).summary?, 'data-name' => 'Wanted to view investors' }
  end

  def permissions_project_statement_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project).statement?, 'data-name' => 'Wanted to view statement' }
  end

  def permissions_project_maturities_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project.rewards.new).index?, 'data-name' => 'Wanted to view maturities' }
  end

  def permissions_project_faqs_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project.project_faqs.new).index?, 'data-name' => 'Wanted to view FAQ' }
  end

  def permissions_project_budget_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project).budget?, 'data-name' => 'Wanted to view budget' }
  end

  def permissions_project_terms_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project.project_documents.new).index?, 'data-name' => 'Wanted to view terms' }
  end

  def permissions_faq_attrs
    { 'data-hyperlink-permission' => policy(:static).faq?, 'data-name' => 'Wanted to view F.A.Q/Help' }
  end
end
