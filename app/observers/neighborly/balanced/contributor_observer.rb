class Neighborly::Balanced::ContributorObserver < ActiveRecord::Observer
  def after_commit(contributor)
    Webhook::EventRegister.new(contributor, created: just_created?(contributor))
  end

  private

  def just_created?(contributor)
    !!contributor.send(:transaction_record_state, :new_record)
  end
end
