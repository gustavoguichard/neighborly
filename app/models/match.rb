class Match < ActiveRecord::Base
  include Shared::PaymentStateMachineHandler,
          Shared::Payable,
          Shared::Notifiable

  belongs_to :project
  belongs_to :user
  has_many :matchings
  has_many :matched_contributions, through: :matchings, source: :contribution

  validates :project, :user, presence: true
  validates :value, numericality: { greater_than_or_equal_to: 1_000 }
  validate :start_and_finish_dates

  scope :active, -> do
    with_state(:confirmed).
      where('starts_at <= :today AND finishes_at >= :today', today: Time.now.utc.to_date)
  end

  def pledged
    Contribution.available_to_count.where(matching_id: matchings).sum(:value)
  end

  private

  def start_and_finish_dates
    ensure_starts_at_in_active_period_of_project
    ensure_finishes_at_after_starts_at_and_in_active_period_of_project
  end

  def ensure_starts_at_in_active_period_of_project
    unless project &&
      (Time.now.utc.beginning_of_day.to_i..project.expires_at.utc.to_i).
        include?(starts_at.to_time.utc.to_i)

      errors.add(
        :starts_at,
        I18n.t('activerecord.errors.models.match.attributes.starts_at.must_be_in_active_period_of_project')
      )
    end
  end

  def ensure_finishes_at_after_starts_at_and_in_active_period_of_project
    unless project &&
      (starts_at.to_time.utc.to_i..project.expires_at.utc.to_i).
        include?(finishes_at.to_time.utc.to_i)

      errors.add(
        :finishes_at,
        I18n.t('activerecord.errors.models.match.attributes.finishes_at.must_be_after_starts_at_and_in_active_period_of_project')
      )
    end
  end
end
