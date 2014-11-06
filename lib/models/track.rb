class Track < Sequel::Model
  plugin :timestamps

  def search_spotify!
    return if self.spotify_id

    r = JSON.parse(Track.spotify_client.get("search", params: {
      type: "track",
      q:    "isrc:#{isrc}"
    }).body)['tracks']['items']

    update(spotify_id: r[0]['id']) if r.length > 0
  end

  def fuzzy_search_spotify
    q = "artist:#{self.artist} album:#{album} title:#{name}"

    r = JSON.parse(Track.spotify_client.get("search", params: {
      type: "track",
      q:    q
    }).body)['tracks']['items']

    puts "#{isrc}, #{artist}, #{album}, #{name}, #{duration}"
    puts q
    dump(r)
    puts "---"
  end

  def dump(r)
    r.each do |t|
      puts "#{t['id']}, #{t['artists'][0]['name']}, #{t['album']['name']}, #{t['name']}, #{t['duration_ms']}"
      puts t["external_ids"]
    end
  end

  def self.rdio_client
    # Unauthorized Rdio client
    # http://www.rdio.com/developers/docs/web-service/oauth/ref-signing-requests
    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuth::AccessToken.new(consumer)
  end

  def self.spotify_client
    # Unauthorized Spotify client
    # https://developer.spotify.com/web-api/authorization-guide/#client_credentials_flow
    # Access token generated with `foreman run bin/keys`
    consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
    client = OAuth2::AccessToken.new(consumer, ENV['SPOTIFY_ACCESS_TOKEN'])
  end

  def self.find_or_create_by_isrc(isrc)
    unless track = Track[isrc: isrc]
      r = JSON.parse(self.rdio_client.post('http://api.rdio.com/1/',
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
    r = JSON.parse(self.spotify_client.get("search", params: {
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
