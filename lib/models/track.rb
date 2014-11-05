class Track < Sequel::Model
  plugin :timestamps

  def self.rdio_client
    # Unauthorized Rdio client
    # http://www.rdio.com/developers/docs/web-service/oauth/ref-signing-requests
    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuth::AccessToken.new(consumer)
  end

  def self.find_or_create_by_isrc(isrc)
    unless track = Track[isrc: isrc]
      client = self.rdio_client
      r = JSON.parse(client.post('http://api.rdio.com/1/',
        method: 'getTracksByISRC',
        isrc:   isrc
        # TODO: extras: ""
      ).body)['result']

      # TODO: is this the right way to handle multiple tracks?
      track = Track.create(
        isrc:     isrc,
        rdio_key: r[0]['key'],
        artist:   r[0]['artist'],
        album:    r[0]['album'],
        name:     r[0]['name'],
        duration: r[0]['duration']
      ).save
    end

    track
  end

  def self.spotify_find_or_create_by_isrc(isrc)
    # Unauthorized Spotify client
    # https://developer.spotify.com/web-api/authorization-guide/#client_credentials_flow
    # Access token generated with `foreman run bin/keys`
    consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
    client = OAuth2::AccessToken.new(consumer, ENV['SPOTIFY_ACCESS_TOKEN'])

    r = JSON.parse(client.get("search", params: {
      type: "track",
      q:    "isrc:#{isrc}"
    }).body)['tracks']['items']

    # TODO: is this the right way to handle multiple tracks?
    track = Track.create(
      isrc:       isrc,
      spotify_id: r[0]['id'],
      artist:     r[0]['artists'][0]['name'],
      album:      r[0]['album']['name'],
      name:       r[0]['name'],
      duration:   r[0]['duration_ms'] / 1000
    ).save
  end
end
