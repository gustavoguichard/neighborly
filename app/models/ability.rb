# coding: utf-8
class Ability
  include CanCan::Ability

  def initialize(current_user, options = {})
    current_user ||= User.new

    can :read, :all

    # NOTE: Update authorizations
    can :access, :updates do |update|
      update.project.user_id == current_user.id
    end
    can :see, :updates do |update|
      !update.exclusive || !current_user.contributions.with_state('confirmed').where(project_id: update.project.id).empty?
    end

    # NOTE: Contribution authorizations
    cannot :show, :contributions
    can :create, :contributions if current_user.persisted?

    can [ :request_refund, :credits_checkout, :show, :update, :edit], :contributions do |contribution|
      contribution.user == current_user
    end

    cannot :update, :contributions, [:user_attributes, :user_id, :user, :value, :payment_service_fee, :payment_id] do |contribution|
      contribution.user == current_user
    end

    # NOTE: admin can access everything.
    # It's the last ability to override all previous abilities.
    can :access, :all if current_user.admin?
  end
end
