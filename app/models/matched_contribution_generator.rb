class MatchedContributionGenerator
  attr_reader :contribution

  def initialize(contribution)
    @contribution = contribution
  end

  def create
    active_matches.each do |match|
      matched_contribution = Contribution.create(attributes(match))
      matching             = Matching.create(
        match_id:        match.id,
        contribution_id: contribution.id
      )
      matched_contribution.update_attribute(:matching_id, matching.id)
    end
  end

  def update
    contribution.matched_contributions.each do |matched_contribution|
      matched_contribution.update_attributes(state: contribution.state)
    end
  end

  protected

  def active_matches
    contribution.project.matches.active
  end

  def attributes(match)
    MatchedContributionAttributes.new(contribution, match).attributes
  end
end
