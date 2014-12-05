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
        spotify_username: env["rack.session"]["spotify_username"],
        import_uuid:      env["rack.session"]["import_uuid"]
      )
    end

    get "/auth/rdio/callback" do
      auth = request.env["omniauth.auth"]
      key  = auth["extra"]["raw_info"]["key"]

      user   = User[env["rack.session"]["uuid"]]
      user ||= User[rdio_key: key]
      user ||= User.create(rdio_key: key)

      user.update(
        rdio_key:       key,
        rdio_username:  auth["extra"]["raw_info"]["username"],
        rdio_token:     auth["credentials"]["token"],
        rdio_secret:    auth["credentials"]["secret"]
      )

      user.save_rdio_playlists!

      env["rack.session"]["uuid"]           = user.uuid
      env["rack.session"]["rdio_username"]  = user.rdio_username

      redirect "/#rdio"
    end

    get "/auth/spotify/callback" do
      auth = request.env["omniauth.auth"]
      id   = auth["extra"]["raw_info"]["id"]

      user   = User[env["rack.session"]["uuid"]]
      user ||= User[spotify_id: id]
      user ||= User.create(spotify_id: id)

      user.update(
        spotify_id:             id,
        spotify_username:       auth["extra"]["raw_info"]["display_name"],
        spotify_token:          auth["credentials"]["token"],
        spotify_refresh_token:  auth["credentials"]["refresh_token"],
        spotify_expires_at:     Time.at(auth["credentials"]["expires_at"]),
      )

      user.save_spotify_playlists!

      env["rack.session"]["uuid"]             = user.uuid
      env["rack.session"]["spotify_username"] = user.spotify_username

      redirect "/#spotify"
    end

    get "/reset" do
      u = User[rdio_username: "nzoschke"]
      u.rdio_playlists_to_a.each do |list|
        list['tracks'].each do |track|
          t = Track[rdio_key: track['key']]
          t.delete if t
        end
      end

      u.delete

      env["rack.session"].clear
      redirect "/"
    end
  end
end
