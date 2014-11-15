
class SpotifyTrackWorker
  include Sidekiq::Worker

  def perform(uuid)
    puts User[uuid].uuid
  end
end