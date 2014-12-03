require "spec_helper"

describe Endpoints::Imports do
  include Rack::Test::Methods

  before do
    @user   = User.create
    @env = { "rack.session" => { "uuid" => @user.uuid } }
  end

  context "Spotify" do
    describe "GET /imports" do
      it "succeeds" do
        get "/imports/spotify", {}, @env
        assert_equal 200, last_response.status
      end
    end
  end
end
