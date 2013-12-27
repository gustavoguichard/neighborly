class ChannelMember < ActiveRecord::Base
  belongs_to :channel
  belongs_to :user
  attr_accessible :user_id, :channel_id
  validates :user_id, :channel_id, presence: true
end
