class User < Sequel::Model
  plugin :timestamps

  def self.find_or_create_by_rdio_key(key)
    User[rdio_key: key] || User.create(rdio_key: key)
  end

  def rdio_playlists_to_a
    return [] if !rdio_playlists

    # TODO: duplicate playlist in different buckets?
    rdio_playlists["owned"] + rdio_playlists["collab"] + rdio_playlists["subscribed"] + rdio_playlists["favorites"]
  end

  def save_rdio_playlists!
    playlists = RdioClient.get_playlists(self)
    update(rdio_playlists: Sequel.pg_json(playlists))

    # Async call match_tracks!
    UserPlaylistsWorker.perform_async(uuid)
  end

  def save_spotify_playlists!(opts={})
    playlists = SpotifyClient.get_playlists(self, opts)
    update(spotify_playlists: Sequel.pg_json(playlists))
  end

  def create_spotify_playlists!
    # assumes all Rdio playlists should be imported and all tracks been matched
    playlist_ids  = []
    update(imported_playlists: playlist_ids)

    rdio_playlists_to_a.each do |playlist|
      name          = "Rdio / #{playlist['name']}"
      track_uris    = []

      playlist["tracks"].each do |track|
        if track = Track[rdio_key: track['key']]
          track_uris << "spotify:track:#{track.spotify_id}" if track.spotify_id
        end
      end

      p = SpotifyClient.create_or_update_playlist(self, name, track_uris)

      # TODO: postgres style update aa set b = array_append(b, 5) where a = 1;
      playlist_ids << p["id"]
      update(imported_playlists: "{#{playlist_ids.join(',')}}")
    end

    imported_playlists
  end

  def match_tracks!
    rdio_playlists_to_a.each do |list|
      list['tracks'].each do |track|

        unless Track[rdio_key: track['key']]
          t = Track.new
          t.rdio_key      = track['key']
          t.rdio_artist   = track['artist']
          t.rdio_album    = track['album']
          t.rdio_name     = track['name']
          t.rdio_duration = track['duration']
          t.rdio_isrcs    = track['isrcs'] # TODO: why doesn't Sequel.pg_array work?!

          t.match_spotify!
        end
      end
    end
  end
end
