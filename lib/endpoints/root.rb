require "json"

module Endpoints
  class Root < Base
    get "/" do
      # Display Rdio and Spotify info or initiate OAuth flow
      redirect "/auth/rdio" unless rdio_credentials = env['rack.session']['rdio_credentials']
      redirect "/auth/spotify" unless spotify_credentials = env['rack.session']['spotify_credentials']

      # TODO: Get the comsumer object from OmniAuth somehow?
      rdio_consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
      rdio_access_token = OAuth::AccessToken.new(rdio_consumer, rdio_credentials['token'], rdio_credentials['secret'])

      rdio_playlists = JSON.parse(rdio_access_token.post('http://api.rdio.com/1/',
        method: 'getPlaylists',
        extras: '[{ "field": "tracks", "extras": [{ "field": "*", "exclude": true }, {"field": "album"}, {"field": "artist"}, {"field": "duration"}, {"field": "isrcs"}, {"field": "key"}, {"field": "name"}] }]'
      ).body)

      spotify_consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
      spotify_access_token = OAuth2::AccessToken.new(spotify_consumer, spotify_credentials['token'])

      # TODO: omniauth-spotify gets the user id, persist in session?
      spotify_user = JSON.parse(spotify_access_token.get('me').body)
      spotify_playlists = JSON.parse(spotify_access_token.get("users/#{spotify_user['id']}/playlists").body)

      "<pre>#{JSON.pretty_generate(spotify_playlists)}</pre>"
    end

    get "/clear" do
      env['rack.session'].clear
      redirect "/"
    end

    get "/auth/rdio/callback" do
      puts request.env['omniauth.auth'].inspect
      env['rack.session']['rdio_credentials'] = request.env['omniauth.auth']['credentials'].to_h
      redirect "/"
    end

    get "/auth/spotify/callback" do
      env['rack.session']['spotify_credentials'] = request.env['omniauth.auth']['credentials'].to_h
      redirect "/"
    end
  end
end
