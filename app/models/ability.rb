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

    # NOTE: Reward authorizations
    can :create, :rewards do |reward|
      reward.project.user == current_user
    end

    can [:update, :destroy], :rewards do |reward|
      reward.contributions.with_state('waiting_confirmation').empty? && reward.contributions.with_state('confirmed').empty? && (reward.project.user == current_user || reward.project.last_channel.try(:user) == current_user || current_user.channels.include?(reward.project.last_channel))
    end

    can [:update, :sort], :rewards, [:title, :description, :maximum_contributions] do |reward|
      reward.project.user == current_user || reward.project.last_channel.try(:user) == current_user || current_user.channels.include?(reward.project.last_channel)
    end

    can :update, :rewards, :days_to_delivery do |reward|
      (reward.project.user == current_user || reward.project.last_channel.try(:user) == current_user || current_user.channels.include?(reward.project.last_channel)) && !reward.project.successful? && !reward.project.failed?
    end

    can :destroy, :authorizations do |authorization|
      authorization.user == current_user || current_user.admin?
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
