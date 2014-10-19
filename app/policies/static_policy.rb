class StaticPolicy < ApplicationPolicy
  def faq?
    is_mvp_beta_user?
  end
end
