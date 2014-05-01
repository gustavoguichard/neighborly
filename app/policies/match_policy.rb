class MatchPolicy < ApplicationPolicy
  def create?
    record.project.online?
  end
end
