class UserPlaylistsWorker
  include Sidekiq::Worker

  def perform(uuid)
    User[uuid].match_tracks!
  end
end
