require "spec_helper"

describe Track do
  before do
    @isrc = "GBAYE9400673"
  end

  it "gets metadata from Rdio by ISRC" do
    t = Track.find_or_create_by_isrc(@isrc)

    assert t.uuid
    assert_equal @isrc, t.isrc
    assert_equal "t2117832", t.rdio_key
    assert_equal "Radiohead", t.artist
    assert_equal "My Iron Lung", t.album
    assert_equal "The Trickster", t.name
    assert_equal 282, t.duration
  end

  it "gets metadata from Spotify by ISRC" do
    t = Track.spotify_find_or_create_by_isrc(@isrc)

    assert t.uuid
    assert_equal @isrc, t.isrc
    assert_equal "5ikIFKeCuGCKX9foh8ToyN", t.spotify_id
    assert_equal "Radiohead", t.artist
    assert_equal "The Bends [Collectors Edition]", t.album
    assert_equal "The Trickster", t.name
    assert_equal 282, t.duration
  end
end
