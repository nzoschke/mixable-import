require 'levenshtein'

class Track < Sequel::Model
  plugin :timestamps

  def name_artist_album_s(h)
    "#{h[:name]} - #{h[:artist]} - #{h[:album]}"
  end

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
      keys:   rdio_key,
      extras: "isrcs"  # TODO: better extras
    ).body)['result'][rdio_key]

    rdio_metadata(r)
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
    r = JSON.parse(Track.spotify_client.get("tracks/#{spotify_id}").body)

    spotify_metadata(r)
  end

  def search_spotify
    qs = [
      "isrc:#{isrc}",
      "track:#{name} artist:#{artist} album:#{album}",
      "track:#{name} artist:#{artist}",
    ]

    @spotify_search_results ||= JSON.parse(ISRC.spotify_client.get("search", params: {
      type: "track",
      q:    qs[0]
    }).body)['tracks']['items']
  end

  def match_by_first_result
    match = search_spotify.first
    { match["id"] => spotify_metadata(match) }
  end

  def match_by_total_edit_distance
    rs = name_artist_album_s(values)

    min_d = rs.length
    match = nil

    search_spotify.each do |r|
      ss = name_artist_album_s(spotify_metadata(r))
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
end