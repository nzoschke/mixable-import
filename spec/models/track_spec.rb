require "spec_helper"

describe Track do
  before do
    @isrc = "GBAYE9400673"
  end

  it "gets rdio and spotify metadata" do
    t = Track.create(rdio_key: "t3160205", spotify_id: "2wEHxTBxLJk3vYzyW6dsAU")
    assert_equal({ :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box (Live)", :duration=>337 }, t.get_rdio)
    assert_equal({ :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box - Live", :duration=>337 }, t.get_spotify)
  end
end
