module Shared::Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, dependent: :destroy

    def notify_owner(template_name, filter = {}, options = {})
      key = self.class.model_name.param_key
      Notification.notify_once(template_name,
                               self.user,
                               { "#{key}_id".to_sym => self.id }.merge(filter),
                               { key.to_sym         => self }.merge(options))
    end
  end
end
