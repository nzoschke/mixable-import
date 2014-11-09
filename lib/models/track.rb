require "base64"
require "levenshtein"
require "net/https"
require "uri"


class Track < Sequel::Model
  plugin :timestamps

  def rdio_metadata(r)
    {
      isrc:     r['isrcs'][0],
      artist:   r['artist'],
      album:    r['album'],
      name:     r['name'],
      duration: r['duration']
    }
  end

  def spotify_metadata(r)
    {
      isrc:       r['external_ids']['isrc'],
      artist:     r['artists'][0]['name'],
      album:      r['album']['name'],
      name:       r['name'],
      duration:   r['duration_ms'] / 1000
    }
  end

  def get_rdio
    r = JSON.parse(Track.rdio_client.post('http://api.rdio.com/1/',
      method: 'get',
      keys:   key,
      extras: "isrcs"  # TODO: better extras
    ).body)['result'][key]

    rdio_metadata(r)
  end

  def search_rdio_isrc
    r = Track.rdio_client.post('http://api.rdio.com/1/',
      method: 'getTracksByISRC',
      keys:   key,
      extras: "isrcs"  # TODO: better extras
    ).parsed['result'][key]
  end

  def spotify_metadata(r)
    {
      isrc:       r['external_ids']['isrc'],
      artist:     r['artists'][0]['name'],
      album:      r['album']['name'],
      name:       r['name'],
      duration:   r['duration_ms'] / 1000
    }
  end

  def get_spotify
    begin
      r = JSON.parse(Track.spotify_client.get("tracks/#{spotify_id}").body)
    rescue OAuth2::Error => e
      if e.code["message"] =~ /token expired/
        Track.spotify_client_refresh!
        retry
      end
    end

    spotify_metadata(r)
  end

  def search_spotify
    begin
      items = []
      isrcs.each do |isrc|
        items += Track.spotify_client.get("search", params: {
          type: "track",
          q:    "isrc:#{isrc}"
        }).parsed['tracks']['items']
      end

      items
    rescue OAuth2::Error => e
      if e.code["message"] =~ /token expired/
        Track.spotify_client_refresh!
        retry
      end
    end
  end

  def match_by_first_result
    # Naive matching for analytics purposes 
    if match = search_spotify.first
      { match["id"] => spotify_metadata(match) }
    else
      { nil => {} }
    end
  end

  def name_artist_album_duration_s(h)
    "#{h[:name]} - #{h[:artist]} - #{h[:album]} - #{h[:duration]}"
  end

  def match_by_total_edit_distance
    rs = name_artist_album_duration_s(values)

    min_d = rs.length + 1
    match = { nil => {} }

    search_spotify.each do |r|
      ss = name_artist_album_duration_s(spotify_metadata(r))
      d = Levenshtein.distance rs, ss

      if d < min_d
        match = { r["id"] => spotify_metadata(r) }
        min_d = d
      elsif d == min_d
        # TODO
      end
    end

    match
  end

  def get_rdio!
    update(get_rdio)
  end

  def match_spotify!
    # spotify_id = match_by_first_result.keys[0]
    spotify_id = match_by_total_edit_distance.keys[0]
    update(spotify_id: spotify_id)
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

  def self.spotify_client_refresh!
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
      ENV["SPOTIFY_ACCESS_TOKEN"] = r["access_token"]
      puts "fn=spotify_client_refresh! code=#{response.code} at=success"
    else
      puts "fn=spotify_client_refresh! code=#{response.code} at=error"
      raise Exception.new("Bad response #{response.body}")
    end
  end
end