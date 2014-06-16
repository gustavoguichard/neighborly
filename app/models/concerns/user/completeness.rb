module User::Completeness
  extend ActiveSupport::Concern

  class Calculator

    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def progress
      send("calc_#{user.profile_type}_progress")
    end

    private
    def calc_personal_progress
      calc_progress %w[name bio location authorizations uploaded_image]
    end

    def calc_organization_progress
      calc_progress %w[bio location authorizations], %w[name image], :organization
    end

    def calc_channel_progress
      100 # Channels are always 100%
    end

    def calc_progress(user_fields, association_fields = [], association_name = nil)
      progress = 0
      user_fields.each do |field|
        progress += 1 if user.send(field).present?
      end

      if association_name.present? && user.send(association_name).present?
        association_fields.each do |field|
          progress += 1 if user.send(association_name).send(field).present?
        end
      end

      (progress / (user_fields + association_fields).size.to_f * 100).to_i
    end

  end

  def update_completeness_progress!
    update_column :completeness_progress, User::Completeness::Calculator.new(self).progress
  end
end
