class Payout < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  class << self
    def complete(project_id, requestor_id)
      payout_handlers.map do |handler|
        handler.new(project_id, requestor_id).complete
      end
    end

    def payout_handlers
      PaymentEngine.all.map do |engine|
        engine.payout_class
      end.uniq
    end
  end
end
