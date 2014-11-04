require "spec_helper"

describe Endpoints::Exports do
  include Rack::Test::Methods

  describe "GET /exports" do
    it "succeeds" do
      get "/exports"
      assert_equal 200, last_response.status
    end

    it "POST /exports with an rdio_user_id to enqueue a new job" do
      post "/exports", { foo: "bar" }
      assert_equal 201, last_response.status
    end
  end
end
