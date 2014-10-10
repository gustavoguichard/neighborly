class OrganizationObserver < ActiveRecord::Observer
  def after_commit(organization)
    Webhook::EventRegister.new(organization, created: just_created?(organization))
  end

  private

  def just_created?(organization)
    !!organization.send(:transaction_record_state, :new_record)
  end
end
