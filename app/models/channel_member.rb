class ChannelMember < ActiveRecord::Base
  belongs_to :channel
  belongs_to :user
  validates :user_id, :channel_id, presence: true
end
