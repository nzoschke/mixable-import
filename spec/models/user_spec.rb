require "spec_helper"

describe User do
  before do
    @rdio_key = "s3385"
    @user     = User.find_or_create_by_rdio_key("s3385")

    @user.update(
      rdio_username:          "nzoschke",
      rdio_token:             ENV["RDIO_USER_TOKEN"],
      rdio_secret:            ENV["RDIO_USER_SECRET"],

      spotify_id:             "mixable.net",
      spotify_username:       "Mixable Dot Net",
      spotify_token:          ENV['SPOTIFY_USER_TOKEN'],
      spotify_refresh_token:  ENV['SPOTIFY_USER_REFRESH_TOKEN'],
      spotify_expires_at:     Time.at(1416241913),
    )
  end

  context "Rdio" do
    it "finds an existing user by Rdio key" do
      u2 = User.find_or_create_by_rdio_key @rdio_key
      assert_equal @user.uuid, u2.uuid
    end

    it "saves a JSON snapshot of Rdio playlists" do
      expect(RdioPlaylistsWorker).to receive(:perform_async) {}

      @user.save_rdio_playlists!
      assert_equal "April Fools!", @user.rdio_playlists["owned"][1]["name"]

      # TODO: How to query into the JSON?!
      # User.db["SELECT * FROM users WHERE 'April Fools!' IN (SELECT value->>'name' FROM json_array_elements(playlists))"].all.inspect
      # Sequel::DatabaseError:
      #   PG::InvalidParameterValue: ERROR:  cannot call json_array_elements on a non-array
    end

    it "gets playlists" do
      expect(RdioPlaylistsWorker).to receive(:perform_async) {}
      @user.save_rdio_playlists!
    end
  end

  context "Spotify" do
    it "saves Spotify access information" do
      u = User[spotify_id: "mixable.net"]

      assert_equal "mixable.net", u.spotify_id
      assert_equal ENV['SPOTIFY_USER_TOKEN'], u.spotify_token
      assert_equal ENV['SPOTIFY_USER_REFRESH_TOKEN'], u.spotify_refresh_token
    end

    it "refreshes an access token" do
      assert @user.spotify_expires_at < Time.now
      SpotifyClient.refresh!(@user)
      assert @user.spotify_expires_at > Time.now
    end

    it "gets Spotify playlists" do
      # expect(SpotifyPlaylistsWorker).to receive(:perform_async) {}

      @user.save_spotify_playlists!
      playlists = @user.spotify_playlists

      assert_equal 7, playlists["total"]
      assert_equal 7, playlists["items"].length
    end

    it "gets Spotify playlists with pagination" do
      @user.save_spotify_playlists!(limit: 1)
      playlists = @user.spotify_playlists

      assert_equal 7, playlists["total"]
      assert_equal 7, playlists["items"].length
    end

    it "gets Spotify playlists and tracks with pagination" do
      @user.save_spotify_playlists!(limit: 1)
      @user.save_spotify_playlist_tracks!(limit: 1)

      playlist = @user.spotify_playlists["items"][0]
      assert_equal 12, playlist["tracks"]["total"]
      assert_equal 12, playlist["tracks"]["items"].length
    end

    it "creates or updates a Spotify playlist" do
      p1 = SpotifyClient.create_or_update_playlist(@user, "Rdio / Feist", ["spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M"])
      assert_equal 2, p1["tracks"]["total"]

      p2 = SpotifyClient.create_or_update_playlist(@user, "Rdio / Feist", ["spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M"])
      assert_equal p1["id"], p2["id"]
    end

    it "cannot create a playlist with local tracks" do
      e = assert_raises OAuth2::Error do
        SpotifyClient.create_or_update_playlist(@user, "Local?!", ["spotify:local:Rinocerose:mixable001:Cubicle:193"])
      end

      assert e.message =~ /JSON body contains an invalid track uri: spotify:local/
    end
  end

  context "Rdio and Spotify" do
    it "creates no spotify playlists if there are no Rdio playlists" do
      @user.start_spotify_import!(created_at: Time.at(0), updated_at: Time.at(0))
      p = @user.create_spotify_playlists!
      assert_equal({ :created_at=>Time.at(0), :updated_at=>Time.at(0), :total=>0, :added=>0, :processed=>0, :items=>[] }, p)
      assert_equal({ :created_at=>Time.at(0), :updated_at=>Time.at(0), :total=>0, :added=>0, :processed=>0, :items=>[] }, @user.spotify_imports)
    end

    it "creates spotify playlists from an Rdio playlist and matched tracks" do
      expect(RdioPlaylistsWorker).to receive(:perform_async) {}

      @user.save_rdio_playlists!
      @user.match_tracks!
      @user.start_spotify_import!(created_at: Time.at(0), updated_at: Time.at(0))
      @user.create_spotify_playlists!

      assert_equal 4, @user.rdio_playlists_to_a.length
      assert_equal(
        { :created_at=>Time.at(0), :updated_at=>Time.at(0), :total=>4, :added=>4, :processed=>4, :items=>["0OdRtoI4Sk4Ts1sALNuiWN", "4BHE88Vl90BnQK17nG2qv4", "5nkYmgsA1XkOHnlw1vEiNs", "5nkYmgsA1XkOHnlw1vEiNs"] },
        @user.spotify_imports
      )
    end
  end

  xcontext "fixtures" do
    before do
      Dir["analytics/*.json"].each do |path|
        values = JSON.parse(File.read(path))
        values.reject! { |k,v| ["uuid", "created_at", "updated_at"].include? k }

        values["rdio_playlists"] = Sequel.pg_json(values.delete "playlists")

        values["rdio_key"]      = values.delete "key"
        values["rdio_username"] = values.delete "url"
        values["rdio_token"]    = values.delete "token"
        values["rdio_secret"]   = values.delete "secret"

        User.create(values)
      end
    end

    it "analytics" do
      
    end
  end
end
