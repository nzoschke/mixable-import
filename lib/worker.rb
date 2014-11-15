class UserPlaylistsWorker
  include Sidekiq::Worker

  def perform(uuid)
    user = User[uuid]
    puts user

    tracks = user.save_tracks!
    tracks.each do |track|
      TrackWorker.perform_async(track.uuid)
    end
  end
end

class TrackWorker
  include Sidekiq::Worker

  def perform(uuid)
    track = Track[uuid]
    puts track

    Track[uuid].match_spotify!
  end
end