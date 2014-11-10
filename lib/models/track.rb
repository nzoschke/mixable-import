require "base64"
require "levenshtein"
require "net/https"
require "uri"

class Track < Sequel::Model
  plugin :timestamps

  def match_by_first_result
    # Naive matching for analytics purposes 
    if match = SpotifyClient.search_by_isrcs(rdio_isrcs).first
      { match["id"] => SpotifyClient.metadata(match) }
    else
      { nil => {} }
    end
  end

  def name_artist_album_duration_s(h)
    "#{h[:name]} - #{h[:artist]} - #{h[:album]} - #{h[:duration]}"
  end

  def match_by_total_edit_distance
    rs = "#{rdio_name} - #{rdio_artist} - #{rdio_album} - #{rdio_duration}"

    min_d = rs.length + 1
    match = { nil => {} }

    SpotifyClient.search_by_isrcs(rdio_isrcs).each do |r|
      ss = name_artist_album_duration_s(SpotifyClient.metadata(r))
      d = Levenshtein.distance rs, ss

      if d < min_d
        match = { r["id"] => SpotifyClient.metadata(r) }
        min_d = d
      elsif d == min_d
        # TODO
      end
    end

    match
  end

  def match_spotify!
    matches = match_by_total_edit_distance

    spotify_id = matches.keys[0]
    match = matches[spotify_id]

    isrcs = []
    matches.each do |id, h|
      isrcs << h[:isrc]
    end

    update(
      spotify_id:           spotify_id,
      spotify_name:         match[:name],
      spotify_album:        match[:album],
      spotify_artist:       match[:artist],
      spotify_duration_ms:  match[:duration_ms],
      spotify_isrcs:        "{#{isrcs.compact.join(',')}}",
      isrc:                 match[:isrc]
    )
  end
end

module RdioClient
  def self.metadata(r)
    # Turns a response item into a normalized metadata hash
    {
      isrc:         r['isrcs'][0],
      artist:       r['artist'],
      album:        r['album'],
      name:         r['name'],
      duration:     r['duration'],
      duration_ms:  r['duration'] * 1000
    }
  end

  def self.get_track(track)
    JSON.parse(RdioClient.unauthorized_client.post('http://api.rdio.com/1/',
      method: 'get',
      keys:   track.rdio_key,
      extras: "isrcs"  # TODO: better extras for efficiency
    ).body)['result'][track.rdio_key]
  end

  def self.get_user(user)
    JSON.parse(RdioClient.authorized_client(user).post('http://api.rdio.com/1/',
      method: 'currentUser'
    ).body)['result']
  end

  def self.get_playlists(user)
    JSON.parse(RdioClient.authorized_client(user).post('http://api.rdio.com/1/',
      method: 'getPlaylists',
      extras: '[{ "field": "tracks", "extras": [{ "field": "*", "exclude": true }, {"field": "album"}, {"field": "artist"}, {"field": "duration"}, {"field": "isrcs"}, {"field": "key"}, {"field": "name"}] }]'
    ).body)['result']
  end

  def self.unauthorized_client
    # Unauthorized Rdio client
    # http://www.rdio.com/developers/docs/web-service/oauth/ref-signing-requests
    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuth::AccessToken.new(consumer)
  end

  def self.authorized_client(user)
    # Authorized Rdio client
    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuth::AccessToken.new(consumer, user.token, user.secret)
  end
end

module SpotifyClient
  @@client_access_token = nil
  @@client_access_token_expires_at = Time.now - 10

  # Turns a response item into a normalized metadata hash
  def self.metadata(r)
    {
      isrc:         r['external_ids']['isrc'],
      artist:       r['artists'][0]['name'],
      album:        r['album']['name'],
      name:         r['name'],
      duration:     r['duration_ms'] / 1000,
      duration_ms:  r['duration_ms']
    }
  end

  def self.get_track(track)
    SpotifyClient.unauthorized_client.get("tracks/#{track.spotify_id}").parsed
  end

  def self.search_by_isrcs(isrcs)
    isrcs.map do |isrc|
      SpotifyClient.unauthorized_client.get("search", params: {
        type: "track",
        q:    "isrc:#{isrc}"
      }).parsed['tracks']['items']
    end.flatten
  end

  def self.unauthorized_client
    # Unauthorized Spotify client
    # https://developer.spotify.com/web-api/authorization-guide/#client_credentials_flow

    SpotifyClient.request_client_access_token
    consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
    client = OAuth2::AccessToken.new(consumer, @@client_access_token)
  end

  def self.request_client_access_token
    return if Time.now <= @@client_access_token_expires_at

    auth = Base64.strict_encode64("#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}")

    uri = URI.parse("https://accounts.spotify.com/api/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.add_field("Authorization", "Basic #{auth}")
    request.set_form_data({ "grant_type" => "client_credentials" })

    response = http.request(request)

    if response.code == "200"
      r = JSON.parse(response.body)
      puts "fn=spotify_client_refresh! code=#{response.code} at=success"
      @@client_access_token = r["access_token"]
      @@client_access_token_expires_at = Time.now + r["expires_in"].to_i
    else
      puts "fn=spotify_client_refresh! code=#{response.code} at=error"
      raise Exception.new("Bad response #{response.body}")
    end
  end
end