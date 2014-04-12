module Shared
  module LocationHandler
    extend ActiveSupport::Concern

    included do
      geocoded_by :location
      after_validation :geocode
    end

    def location=(location)
      array = location.split(',')
      self.address_city = array[0].lstrip.titleize if array[0]
      self.address_state = array[1].lstrip.upcase if array[1]

      if not location.present?
        self.address_city = self.address_state = nil
      end
    end

    def location
      [address_city, address_state].select { |a| a.present? }.compact.join(', ')
    end
  end
end

