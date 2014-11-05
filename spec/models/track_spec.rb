require "spec_helper"

describe Track do
  before do
    @rdio_credentials = { "token" => ENV['RDIO_USER_TOKEN'], "secret" => ENV['RDIO_USER_SECRET'] }
    @isrc = "GBAYE9400673"
  end

  it "gets metadata from Rdio by ISRC" do
    t = Track.find_or_create_by_isrc(@isrc)

    assert t.uuid
    assert_equal @isrc, t.isrc
  end
end
