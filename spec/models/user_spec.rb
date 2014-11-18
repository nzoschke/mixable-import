require "spec_helper"

describe User do
  before do
    @credentials = { "token" => ENV['RDIO_USER_TOKEN'], "secret" => ENV['RDIO_USER_SECRET'] }
    @user = User.find_or_create_by_credentials @credentials

    @user.update_spotify({
      "token"         =>  ENV['SPOTIFY_USER_TOKEN'],
      "refresh_token" =>  ENV['SPOTIFY_USER_REFRESH_TOKEN'],
      "expires_at"    =>  1416241913,
    }, "mixable.net")
  end

  context "Rdio" do
    it "creates a new user by Rdio OAuth credentials" do
      @user.delete

      u = User.find_or_create_by_credentials @credentials

      assert u.uuid
      assert_equal "s3385", u.key
      assert_equal "/people/nzoschke/", u.url
      assert_equal ENV['RDIO_USER_TOKEN'], u.token
      assert_equal ENV['RDIO_USER_SECRET'], u.secret
    end

    it "finds an existing user by Rdio OAuth credentials" do
      u2 = User.find_or_create_by_credentials @credentials
      assert_equal @user.uuid, u2.uuid
    end

    it "saves a JSON snapshot of Rdio playlists" do
      expect(UserPlaylistsWorker).to receive(:perform_async) {}

      @user.save_playlists!
      assert_equal "April Fools!", @user.playlists["owned"][1]["name"]

      # TODO: How to query into the JSON?!
      # User.db["SELECT * FROM users WHERE 'April Fools!' IN (SELECT value->>'name' FROM json_array_elements(playlists))"].all.inspect
      # Sequel::DatabaseError:
      #   PG::InvalidParameterValue: ERROR:  cannot call json_array_elements on a non-array
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
  end

  context "fixtures" do
    before do
      Dir["analytics/*.json"].each do |path|
        values = JSON.parse(File.read(path))
        values.reject! { |k,v| ["uuid", "created_at", "updated_at"].include? k }
        values["playlists"] = Sequel.pg_json(values["playlists"])
        User.create(values)
      end
    end

    it "analytics" do
      
    end
  end
end
