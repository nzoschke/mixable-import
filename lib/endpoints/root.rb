require "json"
require_relative "../worker"

module Endpoints
  class Root < Base
    get "/" do
      redirect '/index.html'
    end

    get "/session" do
      content_type :json, charset: 'utf-8'
      halt 401, '{"error": "No OAuth Session"}' unless user_uuid = env['rack.session']['user_uuid']
      user = User[user_uuid]

      encode({
        uuid: user.uuid,
        url:  user.url,

        rdio_token:       !!user.token,
        spotify_token:    !!user.spotify_token,

        tracks_total:     user.tracks_total,
        tracks_processed: user.tracks_processed
      })
    end

    get "/logout" do
      env['rack.session'].clear
      redirect "/"
    end

    get "/auth/rdio/callback" do
      user = User.find_or_create_by_credentials(request.env['omniauth.auth']['credentials'].to_h)
      user.save_playlists!

      env['rack.session']['user_uuid'] = user.uuid
      redirect "/"
    end

    get "/auth/spotify/callback" do
      halt 401, '{"error": "No OAuth Session"}' unless user_uuid = env['rack.session']['user_uuid']
      user = User[user_uuid]

      creds = request.env['omniauth.auth']['credentials'].to_h
      raw_info = request.env['omniauth.auth']['extra']['raw_info'].to_h

      user.update(
        spotify_token:          creds["token"],
        spotify_refresh_token:  creds["refresh_token"],
        spotify_expires_at:     Time.at(creds["expires_at"]),
        spotify_id:             raw_info["id"]
      )

      redirect "/"
    end
  end
end
