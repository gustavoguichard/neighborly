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
end
