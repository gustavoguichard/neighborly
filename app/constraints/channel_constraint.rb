class ChannelConstraint
  def self.matches?(request)
    Channel.pluck(:permalink).include? request.subdomain
  end
end
