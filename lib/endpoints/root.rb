require "json"

module Endpoints
  class Root < Base
    get "/" do
      # Display Rdio and Spotify info or initiate OAuth flow

      unless rdio_access_token = env['rack.session'][:rdio_access_token]
        redirect "/auth/rdio"
      end

      r = JSON.parse(rdio_access_token.post('http://api.rdio.com/1/',
        method: 'getPlaylists',
        extras: '[{ "field": "tracks", "extras": [{ "field": "*", "exclude": true }, {"field": "album"}, {"field": "artist"}, {"field": "duration"}, {"field": "isrcs"}, {"field": "key"}, {"field": "name"}] }]'
      ).body)
      "<pre>#{JSON.pretty_generate(r)}</pre>"
    end

    get "/clear" do
      env['rack.session'][:rdio_access_token] = nil
      redirect "/"
    end

    get "/auth/rdio/callback" do
      env['rack.session'][:rdio_access_token] = request.env['omniauth.auth']['extra']['access_token']
      redirect "/"
    end
  end
end
