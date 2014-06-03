class SubscriberReport < ActiveRecord::Base
  belongs_to :channel
  acts_as_copy_target

  def read_only?
    true
  end
end
