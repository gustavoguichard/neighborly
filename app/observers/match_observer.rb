class MatchObserver < ActiveRecord::Observer
  observe :match

  def from_confirmed_to_canceled(match)
    match.matched_contributions.each do |contribution|
      contribution.cancel!
    end
  end

  def completed(match)
    match.notify_owner(:match_ended)
  end

  def match_been_met(match)
    match.notify_owner(:match_been_met)
    match.original_contributions.with_state(:confirmed).each do |contribution|
      contribution.notify_owner(:contribution_match_was_met)
    end
  end
end
