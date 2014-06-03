class MatchObserver < ActiveRecord::Observer
  include ActionView::Helpers::NumberHelper

  def from_confirmed_to_canceled(match)
    match.matched_contributions.each do |contribution|
      contribution.cancel!
    end
  end

  def completed(match)
    match.notify_owner(:match_ended)
  end

  def became_active(match)
    update_message = I18n.t('updates.match_became_active',
      image:            match.user.display_image,
      match_start_date: match.starts_at,
      match_end_date:   match.finishes_at,
      matcher_name:     match.user.display_name,
      project_name:     match.project.name,
      value:            number_to_currency(match.value),
      value_unit:       number_to_currency(match.value_unit)
    )

    match.project.updates.create(
      comment: update_message,
      user:    match.project.user
    )
  end

  def match_been_met(match)
    match.notify_owner(:match_been_met)
    match.original_contributions.with_state(:confirmed).each do |contribution|
      contribution.notify_owner(:contribution_match_was_met)
    end
  end
end
