class ChannelsSubscriber < ActiveRecord::Base
  attr_accessible :user_id, :channel_id, :user, :channel

  belongs_to :user
  belongs_to :channel

  validates_presence_of :user_id, :channel_id
end
