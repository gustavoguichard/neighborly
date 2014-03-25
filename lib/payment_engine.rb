class PaymentEngine
  mattr_accessor :engines
  self.engines = []

  def initialize(engine)
    @engine = engine
  end

  def save
    self.engines.push @engine
  end

  class << self
    def all
      engines
    end

    def destroy_all
      engines.clear
    end

    def create_payment_notification(attributes)
      PaymentNotification.create!(attributes)
    end

    def configuration
      ::Configuration
    end

    def find_payment(filter)
      Contribution.find_by(filter)
    end
  end
end
