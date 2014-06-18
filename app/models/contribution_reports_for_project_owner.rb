class ContributionReportsForProjectOwner
  include ActiveModel::Serialization
  include Enumerable

  attr_accessor :project, :conditions

  def initialize(project, conditions = {})
    @project, @conditions = project, conditions
  end

  def all
    contributions
  end

  def each(&block)
    contributions.each do |contribution|
      block.call(contribution)
    end
  end

  private

  def contributions
    @contributions ||= project.contributions.with_state(:confirmed).where(conditions).map do |c|
      ContributionForProjectOwner.new(c)
    end
  end
end
