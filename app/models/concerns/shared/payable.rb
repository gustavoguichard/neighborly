module Shared::Payable
  extend ActiveSupport::Concern

  included do
    has_many :payment_notifications
  end

  def price_in_cents
    (self.value * 100).round
  end

  def define_key!
    self.update_attributes({ key: Digest::MD5.new.update("#{self.id}###{self.created_at}###{Kernel.rand}").to_s })
  end
end
