require "json"

module Endpoints
  class Root < Base
    get "/" do
      # Display Rdio and Spotify info or initiate OAuth flow
      redirect "/auth/rdio" unless rdio_credentials = env['rack.session']['rdio_credentials']

      # TODO: Get the comsumer object from OmniAuth somehow?
      rdio_consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
      rdio_access_token = OAuth::AccessToken.new(rdio_consumer, rdio_credentials['token'], rdio_credentials['secret'])

      r = JSON.parse(rdio_access_token.post('http://api.rdio.com/1/',
        method: 'getPlaylists',
        extras: '[{ "field": "tracks", "extras": [{ "field": "*", "exclude": true }, {"field": "album"}, {"field": "artist"}, {"field": "duration"}, {"field": "isrcs"}, {"field": "key"}, {"field": "name"}] }]'
      ).body)
      "<pre>#{JSON.pretty_generate(r)}</pre>"
    end

    get "/clear" do
      env['rack.session'].clear
      redirect "/"
    end

    get "/auth/rdio/callback" do
      env['rack.session']['rdio_credentials'] = request.env['omniauth.auth']['credentials'].to_h
      redirect "/"
    end
  end
end
