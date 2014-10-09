module Webhook
  class UnauthenticatedRequest < RuntimeError; end

  class EventReceiver
    EVENTS = ['user.created', 'user.updated', 'contributor.created', 'contributor.updated']

    attr_accessor :params

    def initialize(params)
      @params = params
      if params[:record].present?
        @params[:record] = ActiveSupport::JSON.decode(params[:record].to_s).with_indifferent_access
      end
    end

    def process_request
      if valid_request?
        if EVENTS.include?(params[:type])
          send(params[:type].sub('.', '_'), params[:record])
        end
      else
        raise UnauthenticatedRequest
      end
    end

    private

    def user_updated(record)
      user = User.find(record.delete(:id))

      user.update_columns(record) if user
    end

    def user_created(record)
      User.observers.disable :all do
        user = User.new(record)
        user.referral_code = SecureRandom.urlsafe_base64

        user.save(validate: false)
      end
    end

    def contributor_updated(record)
      contributor = Neighborly::Balanced::Contributor.find(record.delete(:id))

      contributor.update_columns(record) if contributor
    end

    def contributor_created(record)
      Neighborly::Balanced::Contributor.observers.disable :all do
        contributor = Neighborly::Balanced::Contributor.new(record)
        contributor.save(validate: false)
      end
    end

    def valid_request?
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new,
                              Configuration[:webhook_secret_key],
                              params[:record].to_s) == params[:authentication_key]
    end
  end
end
