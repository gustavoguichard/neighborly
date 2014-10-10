module Webhook
  class UnauthenticatedRequest < RuntimeError; end

  class EventReceiver
    EVENTS = [
      'authorization.created',
      'contributor.created',
      'organization.created',
      'user.created',
      'authorization.updated',
      'contributor.updated',
      'organization.updated',
      'user.updated'
    ]

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
          EventProcessor.new(params[:record]).send(params[:type].sub('.', '_'))
        end
      else
        raise UnauthenticatedRequest
      end
    end

    def valid_request?
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new,
                              Configuration[:webhook_secret_key],
                              params[:record].to_s) == params[:authentication_key]
    end
  end
end
