class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :channel
  belongs_to :contribution
  belongs_to :contact

  validates_presence_of :user

  def self.notify_once(template_name, user, filter, params = {})
    self.notify(template_name, user, params) if is_unique?(template_name, filter)
  end

  private

  def self.is_unique?(template_name, filter)
    filter.nil? || where(filter.merge(template_name: template_name)).empty?
  end

  def self.notify(template_name, user, params = {})
    notification_params = {
      locale:        user.locale || I18n.locale,
      origin_email:  Configuration[:email_contact],
      origin_name:   Configuration[:company_name],
      template_name: template_name,
      user:          user
    }.merge(params)
    create!(notification_params)
  end
end
