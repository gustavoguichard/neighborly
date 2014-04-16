module Shared
  module LocationHandler
    extend ActiveSupport::Concern

    included do
      geocoded_by :location
      after_validation :geocode
    end

    def location=(location)
      self.address_city, self.address_state = location.split(', ').
        compact.map(&:lstrip) if location.present?
    end

    def address_city=(city)
      write_attribute(:address_city, city.to_s.titleize)
    end

    def address_state=(state)
      write_attribute(:address_state, state.to_s.upcase)
    end

    def location
      [address_city, address_state].select(&:present?).compact.join(', ')
    end
  end
end

