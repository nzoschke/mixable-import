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

  # TODO: test matchers via stubs/mocks
  it "matches an rdio_key to a spotify_id by first result" do
    t = Track[key: "t3160205"]
    m = t.match_by_first_result
    assert_equal({ "4XuHSTkpToHdZgxp0xar6i" => { :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box - Live", :duration=>337 } }, m)
  end

  it "matches an rdio_key to a spotify_id by total edit distance" do
    t = Track[key: "t3160205"]
    m = t.match_by_total_edit_distance
    assert_equal({ "4XuHSTkpToHdZgxp0xar6i" => { :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box - Live", :duration=>337 } }, m)
  end
end
