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

  def start_spotify_import!(opts={})
    created_at = opts[:created_at] || Time.now
    updated_at = opts[:updated_at] || Time.now
    expires_in = opts[:expires_in] || 120

    # Verify that track matching is not in progress
    playlists = Serializers::Playlist.new(:rdio).serialize(rdio_playlists_to_a)

    total     = 0
    processed = 0

    playlists.each do |playlist|
      total     += playlist[:tracks][:total]
      processed += playlist[:tracks][:processed]
    end

    if processed < total
      raise ImportError.new("Track matching in progress")
    end

    if spotify_imports
      raise ImportError.new("Import in progress") unless spotify_imports[:created_at] < created_at - expires_in
    end

    update(spotify_imports: Sequel.pg_json({
      created_at: created_at,
      updated_at: updated_at,
      total:      rdio_playlists_to_a.count,
      added:      0,
      processed:  0,
      items:      []
    }))

    spotify_imports
  end

  def save_rdio_playlists!
    playlists = RdioClient.get_playlists(self)
    update(rdio_playlists: Sequel.pg_json(playlists))
    RdioPlaylistsWorker.perform_async(uuid) # Async call match_tracks!
  end

  def save_spotify_playlists!(opts={})
    playlists = SpotifyClient.get_playlists(self, opts)
    update(spotify_playlists: Sequel.pg_json(playlists))
    # SpotifyPlaylistsWorker.perform_async(uuid) # async call get_spotify_playlist_tracks!
  end

  def save_spotify_playlist_tracks!(opts={})
    playlists = spotify_playlists

    playlists["items"].each_with_index do |playlist, i|
      tracks = SpotifyClient.get_playlist_tracks(self, playlist["id"], opts)
      playlists["items"][i]["tracks"] = tracks

      self.spotify_playlists = Sequel.pg_json(playlists)
      self.save
    end
  end

  def create_spotify_playlists!
    imports = spotify_imports

    rdio_playlists_to_a.each do |playlist|
      name          = "Rdio / #{playlist['name']}"
      track_uris    = []

      playlist["tracks"].each do |track|
        if track = Track[rdio_key: track['key']]
          track_uris << "spotify:track:#{track.spotify_id}" if track.spotify_id
        end
      end

      p = SpotifyClient.create_or_update_playlist(self, name, track_uris)

      # TODO: failures and duplicates?
      imports[:added]     += 1
      imports[:processed] += 1
      imports[:items]     << p["id"]

      # FIXME: why doesn't update work?!
      spotify_imports = Sequel.pg_json(imports)
      save
    end

    imports
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

class ImportError < Exception ; end
