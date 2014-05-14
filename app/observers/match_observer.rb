class MatchObserver < ActiveRecord::Observer
  observe :match

  def cancel_matched_contributions(match)
    match.matched_contributions.each do |contribution|
      contribution.cancel!
    end
  end
end
