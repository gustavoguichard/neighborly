class MatchFinisher
  def complete!
    matches.each do |match|
      refund = Neighborly::Balanced::Refund.new(match)
      refund.complete!(:match_automatic, remaining_amount_of(match))
      match.complete!
    end
  end

  def remaining_amount_of(match)
    match.value -
      match.matched_contributions.with_state(:confirmed).sum(:value)
  end

  def matches
    projects_waiting_contributions =
      Contribution.with_state(:waiting_confirmation).
        group(:project_id).pluck(:project_id)
    Match.with_state(:confirmed).
      not_completed.
      where('finishes_at < ?', Time.now.utc).
      where.not(project_id: projects_waiting_contributions)
  end
end
