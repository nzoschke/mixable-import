require "spec_helper"

describe Endpoints::Imports do
  include Rack::Test::Methods

  describe "GET /imports" do
    it "succeeds" do
      get "/imports"
      assert_equal 200, last_response.status
    end
  end
end
