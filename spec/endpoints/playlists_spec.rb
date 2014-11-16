require "spec_helper"

describe Endpoints::Playlists do
  include Rack::Test::Methods

  describe "GET /playlists" do
    it "succeeds" do
      get "/playlists"
      assert_equal 200, last_response.status
    end
  end
end
