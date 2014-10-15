module PermissionsHelper
  def permissions_discover_attrs
    { 'data-hyperlink-permission' => policy(Project).discover?, 'data-name' => 'Wanted to discover issuances' }
  end

  def permissions_project_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project).show?, 'data-name' => 'Wanted to view issuance' }
  end
end
