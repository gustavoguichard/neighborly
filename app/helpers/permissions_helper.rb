module PermissionsHelper
  def permissions_discover_attrs
    { 'data-hyperlink-permission' => policy(Project).discover?, 'data-name' => 'Discover issuances' }
  end
end
