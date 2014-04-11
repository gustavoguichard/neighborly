class Payout < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  def self.complete(project_id, requestor)
    payout_handlers.map do |handler|
      handler.new(project_id, requestor).complete
    end
  end

  def self.payout_handlers
    PaymentEngine.all.map do |engine|
      engine.payout_class
    end.uniq
  end
end
