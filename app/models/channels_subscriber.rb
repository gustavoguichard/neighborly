class ChannelsSubscriber < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel

  validates_presence_of :user_id, :channel_id
end
