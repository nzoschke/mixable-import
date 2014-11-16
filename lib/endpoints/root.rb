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

      encode user.values.select { |k,v| [:uuid, :url].include? k }
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
      env['rack.session']['spotify_credentials'] = request.env['omniauth.auth']['credentials'].to_h
      redirect "/"
    end
  end
end
