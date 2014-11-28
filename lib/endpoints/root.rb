module Endpoints
  class Root < Base
    get "/" do
      send_file File.expand_path("index.html", settings.public_folder)
    end

    get "/auth" do
      # Poor man's Rack::MethodOverride
      if params["_method"] == "DELETE"
        env["rack.session"].clear
        redirect "/"
      end

      content_type :json, charset: "utf-8"
      halt 401, '{"error": "No OAuth Session"}' unless env["rack.session"]["uuid"]

      encode(
        uuid:             env["rack.session"]["uuid"],
        rdio_username:    env["rack.session"]["rdio_username"],
        spotify_username: env["rack.session"]["spotify_username"]
      )
    end

    get "/auth/rdio/callback" do
      auth = request.env["omniauth.auth"]

      user = User.find_or_create_by_rdio_key(auth["extra"]["raw_info"]["key"])
      user.update(
        rdio_username:  auth["extra"]["raw_info"]["username"],
        rdio_token:     auth["credentials"]["token"],
        rdio_secret:    auth["credentials"]["secret"]
      )

      user.save_rdio_playlists!

      env["rack.session"].clear
      env["rack.session"]["uuid"]           = user.uuid
      env["rack.session"]["rdio_username"]  = user.rdio_username
      redirect "/#rdio"
    end

    get "/auth/spotify/callback" do
      content_type :json, charset: "utf-8"
      halt 401, '{"error": "No OAuth Session"}' unless env["rack.session"]["uuid"]

      auth = request.env["omniauth.auth"]

      user = User[env["rack.session"]["uuid"]]
      user.update(
        spotify_id:             auth["extra"]["raw_info"]["id"],
        spotify_username:       auth["extra"]["raw_info"]["display_name"],
        spotify_token:          auth["credentials"]["token"],
        spotify_refresh_token:  auth["credentials"]["refresh_token"],
        spotify_expires_at:     Time.at(auth["credentials"]["expires_at"]),
        spotify_imports:        nil
      )

      user.save_spotify_playlists!

      env["rack.session"]["spotify_username"] = user.spotify_username
      redirect "/#spotify"
    end
  end
end
