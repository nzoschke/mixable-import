require "spec_helper"

describe Endpoints::Imports do
  include Rack::Test::Methods

  before do
    @user   = User.create
    @env = { "rack.session" => { "uuid" => @user.uuid } }
  end

  context "Spotify" do
    describe "GET /imports" do
      before do
        Import.start_spotify!(@user)
      end

      it "succeeds" do
        get "/imports/spotify", {}, @env
        assert_equal 200, last_response.status

        r = JSON.parse(last_response.body)
        assert_equal 1, r.length
        assert_equal({"total"=>0, "added"=>0, "processed"=>0, "items"=>[]}, r[0]["playlists"])
      end

      it "supports a limit param with default 1" do
        i = Import.start_spotify!(@user)

        get "/imports/spotify", {}, @env
        r = JSON.parse(last_response.body)
        assert_equal 1, r.length
        assert_equal i.uuid, r[0]["id"]

        get "/imports/spotify", { limit: 5 }, @env
        r = JSON.parse(last_response.body)
        assert_equal 2, r.length
        assert_equal i.uuid, r[0]["id"]
      end
    end
  end
end
