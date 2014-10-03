class BrokerageAccountPolicy < ApplicationPolicy
  def new?
    !!user
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def permitted_attributes
    {
      brokerage_account: %i(
        address
        email
        name
        phone
        tax_id
      )
    }
  end
end
