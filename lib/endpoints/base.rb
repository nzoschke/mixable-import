module Endpoints
  # The base class for all Sinatra-based endpoints. Use sparingly.
  class Base < Sinatra::Base
    register Pliny::Extensions::Instruments
    register Sinatra::Namespace

    helpers Pliny::Helpers::Encode
    helpers Pliny::Helpers::Params

    set :dump_errors, false
    set :raise_errors, true
    set :show_exceptions, false
    set :public_folder, 'public'

    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :rdio, ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET']
      provider :spotify, ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], scope: 'playlist-read-private playlist-modify-private'
    end

    configure :development do
      register Sinatra::Reloader
      also_reload '../**/*.rb'
    end

    error Pliny::Errors::Error do
      Pliny::Errors::Error.render(env["sinatra.error"])
    end

    not_found do
      content_type :json
      status 404
      "{}"
    end
  end
end
