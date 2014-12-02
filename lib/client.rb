require "base64"
require "net/https"
require "uri"

class OAuthAccessToken < OAuth::AccessToken
  def request(http_method, path, *arguments)
    request_start = Time.now

    args = arguments[0].map { |k,v| "#{k}=#{v}" if v =~ /^[[:alnum:]]+$/ }.compact.join("&")

    Pliny.log(
      oauth_token:  true,
      at:           "start",
      method:       http_method.upcase,
      path:         "#{path}?#{args}",
    )

    response = super

    Pliny.log(
      oauth_token: true,
      at:          "finish",
      method:      http_method.upcase,
      path:        "#{path}?#{args}",
      status:      response.code,
      elapsed:     (Time.now - request_start).to_f
    )

    response
  end
end

class OAuth2AccessToken < OAuth2::AccessToken
  def request(verb, path, opts = {}, &block)
    request_start = Time.now

    Pliny.log(
      oauth_token:  true,
      at:           "start",
      method:       verb.upcase,
      path:         "#{@client.site}/#{path}",
    )

    response = super

    Pliny.log(
      oauth_token: true,
      at:          "finish",
      method:      verb.upcase,
      path:        "#{@client.site}/#{path}",
      status:      response.status,
      elapsed:     (Time.now - request_start).to_f
    )

    response
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
    OAuthAccessToken.new(consumer)
  end

  def self.authorized_client(user)
    # Authorized Rdio client
    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuthAccessToken.new(consumer, user.rdio_token, user.rdio_secret)
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

  def self.get_playlists(user, params={})
    params[:offset] = 0
    params[:limit]  = params[:limit] || 50

    client = SpotifyClient.authorized_client(user)

    playlists = client.get("users/#{user.spotify_id}/playlists", params: params).parsed

    if playlists["next"]
      while true
        params[:offset] += params[:limit]
        p = client.get("users/#{user.spotify_id}/playlists", params: params).parsed
        playlists["items"] += p["items"]
        break unless p["next"]
      end
    end

    playlists
  end

  def self.get_playlist_tracks(user, playlist_id, params={})
    # TODO: better fields for efficiency
    params[:offset] = 0
    params[:limit]  = params[:limit] || 100

    client = SpotifyClient.authorized_client(user)

    tracks = client.get("users/#{user.spotify_id}/playlists/#{playlist_id}/tracks", params: params).parsed

    if tracks["next"]
      while true
        params[:offset] += params[:limit]
        p = client.get("users/#{user.spotify_id}/playlists/#{playlist_id}/tracks", params: params).parsed
        tracks["items"] += p["items"]
        break unless p["next"]
      end
    end

    tracks
  end

  def self.create_or_update_playlist(user, playlist_name, uris)
    client = SpotifyClient.authorized_client(user)

    playlists = SpotifyClient.get_playlists(user)
    playlist = playlists["items"].detect { |p| p["name"] == playlist_name }

    if !playlist
      playlist = client.post("users/#{user.spotify_id}/playlists", body: JSON.dump({
        name:   playlist_name,
        public: false
      })).parsed
    end

    # Replace all tracks. careful!
    # TODO: delete created playlist if error?
    # TODO: 100 tracks at a time
    client.put("users/#{user.spotify_id}/playlists/#{playlist['id']}/tracks", body: JSON.dump({ uris: uris })).parsed
    client.get("users/#{user.spotify_id}/playlists/#{playlist['id']}").parsed
  end

  def self.unauthorized_client
    # Unauthorized Spotify client
    # https://developer.spotify.com/web-api/authorization-guide/#client_credentials_flow
    SpotifyClient.request_client_access_token
    consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
    client = OAuth2AccessToken.new(consumer, @@client_access_token)
  end

  def self.authorized_client(user)
    # Authorized Spotify client
    SpotifyClient.refresh!(user)
    consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
    client = OAuth2AccessToken.new(consumer, user.spotify_token, { refresh_token: user.spotify_refresh_token, expires_at: user.spotify_expires_at })
  end

  def self.refresh!(user)
    if r = SpotifyClient.post_token(user.spotify_expires_at, { "grant_type" => "refresh_token", "refresh_token" => user.spotify_refresh_token })
      user.update(spotify_token: r["access_token"], spotify_expires_at: Time.now + r["expires_in"])
    end
  end

  def self.request_client_access_token
    if r = SpotifyClient.post_token(@@client_access_token_expires_at, { "grant_type" => "client_credentials" })
      @@client_access_token = r["access_token"]
      @@client_access_token_expires_at = Time.now + r["expires_in"].to_i
    end
  end

  def self.post_token(expires_at, data={})
    return if Time.now < expires_at

    request_start = Time.now
    path = "https://accounts.spotify.com/api/token"

    Pliny.log(
      post_token:   true,
      at:           "start",
      method:       "POST",
      path:         "#{path}",
    )

    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    auth = Base64.strict_encode64("#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}")
    request.add_field("Authorization", "Basic #{auth}")
    request.set_form_data(data)

    response = http.request(request)

    Pliny.log(
      post_token:  true,
      at:          "finish",
      method:      "POST",
      path:        "#{path}",
      status:      response.code,
      elapsed:     (Time.now - request_start).to_f
    )

    if response.code == "200"
      JSON.parse(response.body)
    else
      raise Exception.new("Bad response #{response.body}")
    end
  end
end