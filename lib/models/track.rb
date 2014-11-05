class Track < Sequel::Model
  plugin :timestamps

  def self.find_or_create_by_isrc(isrc)
    unless track = Track[isrc: isrc]
      # client = self.rdio_client(creds)
      # r = JSON.parse(client.post('http://api.rdio.com/1/',
      #   method: 'currentUser'
      # ).body)['result']

      track = Track.create(
        isrc:     isrc,
        # rdio_key: track['key'],
        # artist:   track['artist'],
        # album:    track['album'],
        # name:     track['name'],
        # duration: track['duration']
      ).save
    end

    track
  end
end
