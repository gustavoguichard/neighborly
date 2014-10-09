module Webhook
  class EventProcessor
    attr_accessor :record

    def initialize(record)
      @record = record
    end

    def authorization_created
      Authorization.observers.disable :all do
        authorization = Authorization.new(authorization_attributes)

        authorization.save(validate: false)
      end
    end

    def contributor_created
      Neighborly::Balanced::Contributor.observers.disable :all do
        contributor = Neighborly::Balanced::Contributor.new(contributor_attributes)
        contributor.save(validate: false)
      end
    end

    def organization_created
      Organization.observers.disable :all do
        organization = Organization.new(organization_attributes)

        organization.save(validate: false)
      end
    end

    def user_created
      User.observers.disable :all do
        user = User.new(user_attributes)
        user.referral_code = SecureRandom.urlsafe_base64

        user.save(validate: false)
      end
    end

    def authorization_updated
      authorization = Authorization.find(record.delete(:id))

      authorization.update_columns(authorization_attributes) if authorization
    end

    def contributor_updated
      contributor = Neighborly::Balanced::Contributor.find(record.delete(:id))

      contributor.update_columns(contributor_attributes) if contributor
    end

    def organization_updated
      organization = Organization.find(record.delete(:id))

      organization.update_columns(organization_attributes) if organization
    end

    def user_updated
      user = User.find(record.delete(:id))

      user.update_columns(user_attributes) if user
    end

    private

    def authorization_attributes
      parameters = ActionController::Parameters.new(record)
      parameters.permit(Authorization.attribute_names.map(&:to_sym))
    end

    def contributor_attributes
      parameters = ActionController::Parameters.new(record)
      parameters.permit(Neighborly::Balanced::Contributor.attribute_names.map(&:to_sym))
    end

    def organization_attributes
      parameters = ActionController::Parameters.new(record)
      parameters.permit(Organization.attribute_names.map(&:to_sym))
    end

    def user_attributes
      parameters = ActionController::Parameters.new(record)
      parameters.permit(User.attribute_names.map(&:to_sym))
    end
  end
end

