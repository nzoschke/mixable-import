class User < Sequel::Model
  plugin :timestamps

  def self.find_or_create_by_credentials(creds)
    temp_user = User.new(token: creds['token'], secret: creds['secret'])
    r = RdioClient.get_user(temp_user)

    user = User[key: r['key']] || User.create(key: r['key'], url: r['url'])
    user.update(token: creds['token'], secret: creds['secret'])
    user
  end

  def update_spotify(creds, id)
    update(
      spotify_token:          creds["token"],
      spotify_refresh_token:  creds["refresh_token"],
      spotify_expires_at:     Time.at(creds["expires_at"]),
      spotify_id:             id
    )
  end

  def playlists_to_a
    playlists["owned"] + playlists["collab"] + playlists["subscribed"] + playlists["favorites"]
  end

  def save_playlists!
    playlists = RdioClient.get_playlists(self)
    update(playlists: Sequel.pg_json(playlists))

    # Async call match_tracks!
    UserPlaylistsWorker.perform_async(uuid)
  end

  def match_tracks!
    playlists_to_a.each do |list|
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
