class MatchActivationWorker
  include Sidekiq::Worker

  def perform
    Match.activating_today.each do |match|
      match.notify_observers :became_active
    end
  end
end
