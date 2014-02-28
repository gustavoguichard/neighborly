module Project::OrganizationType
  extend ActiveSupport::Concern

  included do
    class << self
      def organization_type_array
        [['Select an option', '']].concat organization_types.collect { |type| [I18n.t("project.organization_type.#{type}"), type] }
      end

      def organization_types
        [:municipality, :neighborhood_organization, :cid_bid, :registered_nonprofit, :nonprofit_501c3, :public_private_partnership, :other, :not_sure]
      end
    end
  end
end
