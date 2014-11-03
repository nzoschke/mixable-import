require "spec_helper"

describe Endpoints::Exports do
  include Rack::Test::Methods

  describe "GET /exports" do
    it "succeeds" do
      get "/exports"
      assert_equal 200, last_response.status
    end
  end
end
