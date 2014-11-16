class User < Sequel::Model
  plugin :timestamps

  def self.find_or_create_by_credentials(creds)
    temp_user = User.new(token: creds['token'], secret: creds['secret'])
    r = RdioClient.get_user(temp_user)

    user = User[key: r['key']] || User.create(key: r['key'], url: r['url'])
    user.update(token: creds['token'], secret: creds['secret'])
    user
  end

  def playlists_to_a
    playlists["owned"] + playlists["collab"] + playlists["subscribed"] + playlists["favorites"]
  end

  def save_playlists!
    update(playlists: Sequel.pg_json(RdioClient.get_playlists(self)))
    UserPlaylistsWorker.perform_async(uuid)
  end

  def save_tracks!
    tracks = []
    self.playlists.each do |kind, lists|
      lists.each do |list|
        list['tracks'].each do |track|
          next if Track[rdio_key: track['key']]

          tracks << Track.create(
            rdio_key:      track['key'],
            rdio_artist:   track['artist'],
            rdio_album:    track['album'],
            rdio_name:     track['name'],
            rdio_duration: track['duration'],
            rdio_isrcs:    "{#{track['isrcs'].compact.join(',')}}"
            # rdio_isrcs:    Sequel.pg_array(track['isrcs']) # TODO: why doesn't Sequel.pg_array work?!
          )
        end
      end
    end
    tracks
  end

  def playlists_isrcs
    isrcs = []
    self.playlists.each do |kind, lists|
      lists.each do |list|
        list['tracks'].each do |track|
          isrcs.push track['isrcs']
        end
      end
    end
    isrcs.flatten
  end
end
