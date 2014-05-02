class MatchedContributionGenerator
  attr_reader :contribution

  def initialize(contribution)
    @contribution = contribution
  end

  def create
    active_matches = Match.active(contribution.project)
    attrs          = nil
    active_matches.each do |match|
      attrs                = MatchedContributionAttributes.new(contribution, match).attributes
      matched_contribution = Contribution.create(attrs)
      matching             = Matching.create(
        match_id:        match.id,
        contribution_id: contribution.id)
      matched_contribution.update_attribute(:matching_id, matching.id)
    end
  end

  def update
  end
end
