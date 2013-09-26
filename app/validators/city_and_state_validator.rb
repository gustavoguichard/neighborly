class CityAndStateValidator < ActiveModel::Validator
  def validate(record)
    begin
      if record.address_city.present? && record.address_state.present?
        result = Geocoder.search(record.address, params: { countrycodes: "us" })

        if result.first.present?
          record.address_city = result.first.city
          record.address_state = result.first.state_code
        end

        record.errors.add(:address, I18n.t('activerecord.validators.city_and_state.invalid')) unless record.address_city.present? && record.address_state.present?
      elsif not options.include?(:allow_blank)
        record.errors.add(:address, :blank)
      end

    rescue Exception => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end
end
