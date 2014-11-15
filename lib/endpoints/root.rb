require "json"
require_relative "../worker"

module Endpoints
  class Root < Base
    get "/" do
      redirect '/index.html'

      # Display Rdio and Spotify info or initiate OAuth flow
      redirect "/auth/spotify" unless spotify_credentials = env['rack.session']['spotify_credentials']

      spotify_consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
      spotify_access_token = OAuth2::AccessToken.new(spotify_consumer, spotify_credentials['token'])

      # TODO: omniauth-spotify gets the user id, persist in session?
      spotify_user = JSON.parse(spotify_access_token.get('me').body)
      spotify_playlists = JSON.parse(spotify_access_token.get("users/#{spotify_user['id']}/playlists").body)

      "<pre>#{JSON.pretty_generate(spotify_playlists)}</pre>"
    end

    get "/session" do
      content_type :json, charset: 'utf-8'
      halt 401, '{"error": "No OAuth Session"}' unless user_uuid = env['rack.session']['user_uuid']
      user = User[user_uuid]

      encode user.values.select { |k,v| [:uuid, :url].include? k }
    end

    get "/playlists" do
      content_type :json, charset: 'utf-8'
      halt 401, '{"error": "No OAuth Session"}' unless user_uuid = env['rack.session']['user_uuid']
      user = User[user_uuid]

      encode user.playlists
    end

    get "/logout" do
      env['rack.session'].clear
      redirect "/"
    end

    get "/auth/rdio/callback" do
      user = User.find_or_create_by_credentials(request.env['omniauth.auth']['credentials'].to_h)
      user.save_playlists!
      SpotifyTrackWorker.perform_async(user.uuid)

      env['rack.session']['user_uuid'] = user.uuid
      redirect "/"
    end

    get "/auth/spotify/callback" do
      env['rack.session']['spotify_credentials'] = request.env['omniauth.auth']['credentials'].to_h
      redirect "/"
    end
  end
end
