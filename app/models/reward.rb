# coding: utf-8
require 'rails_autolink'
class Reward < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include RankedModel

  include ERB::Util
  schema_associations

  ranks :row_order, with_same: :project_id

  validates_presence_of :minimum_value, :description
  validates_numericality_of :minimum_value, greater_than_or_equal_to: 10.00
  validates_numericality_of :maximum_backers, only_integer: true, greater_than: 0, allow_nil: true
  scope :remaining, -> { where("maximum_backers IS NULL OR (maximum_backers IS NOT NULL AND (SELECT COUNT(*) FROM backers WHERE state IN ('confirmed', 'waiting_confirmation') AND reward_id = rewards.id) < maximum_backers)") }
  scope :sort_asc, -> { order('id ASC') }
  scope :not_soon, -> { where('soon is not true') }
  scope :soon, -> { where(soon: true) }

  def sold_out?
    maximum_backers && total_compromised >= maximum_backers
  end

  def total_compromised
    backers.with_states(['confirmed', 'waiting_confirmation']).count
  end

  def remaining
    return nil unless maximum_backers
    maximum_backers - total_compromised
  end

  def display_deliver_prevision
    I18n.l((project.expires_at + days_to_delivery.days), format: :prevision)
  rescue
    days_to_delivery
  end

  def display_remaining
    I18n.t('reward.display_remaining', remaining: remaining, maximum: maximum_backers).html_safe
  end

  def display_minimum
    number_to_currency minimum_value, precision: 0
  end

  def display_description
    auto_link(simple_format(description), html: {target: :_blank})
  end
end
