# coding: utf-8
class Reward < ActiveRecord::Base
  include RankedModel

  belongs_to :project
  has_many :contributions

  ranks :row_order, with_same: :project_id

  validates_presence_of :title, :minimum_value, :description
  validates_numericality_of :minimum_value, greater_than_or_equal_to: 10.00
  validates_numericality_of :maximum_contributions, only_integer: true, greater_than: 0, allow_nil: true
  scope :remaining, -> { where("maximum_contributions IS NULL OR (maximum_contributions IS NOT NULL AND (SELECT COUNT(*) FROM contributions WHERE state IN ('confirmed', 'waiting_confirmation') AND reward_id = rewards.id) < maximum_contributions)") }
  scope :sort_asc, -> { order('id ASC') }
  scope :not_soon, -> { where('soon is not true') }
  scope :soon, -> { where(soon: true) }

  delegate :display_deliver_prevision, :display_remaining, :name, :display_minimum,
           :medium_description, :last_description, :display_description, to: :decorator
  def decorator
    @decorator ||= RewardDecorator.new(self)
  end

  def sold_out?
    maximum_contributions && total_compromised >= maximum_contributions
  end

  def total_compromised
    contributions.with_states(['confirmed', 'waiting_confirmation']).count
  end

  def remaining
    return nil unless maximum_contributions
    maximum_contributions - total_compromised
  end
end
