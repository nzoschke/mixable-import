class User < Sequel::Model
  plugin :timestamps
  one_to_many :imports, key: :user_uuid

  def self.find_or_create_by_rdio_key(key)
    User[rdio_key: key] || User.create(rdio_key: key)
  end

  def rdio_playlists_to_a
    return [] if !rdio_playlists

    # TODO: duplicate playlist in different buckets?
    (rdio_playlists["owned"] + rdio_playlists["collab"] + rdio_playlists["subscribed"] + rdio_playlists["favorites"]).uniq
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
          t.rdio_isrcs    = track['isrcs'] - ["", nil] # remove empty-ish values before storing in text[] field

          t.match_spotify!
        end
      end
    end
  end
end
