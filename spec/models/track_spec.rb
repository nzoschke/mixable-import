require "spec_helper"

describe Track do
  it "true" do
    assert true
  end

  it "saves to the database" do
    Track.new(isrc: "USRC11301695").save
    t = Track.first
    assert_equal "USRC11301695", t.isrc
  end

  context "Rdio" do
    it "populates track metadata with an rdio_key" do
      t = Track.new(rdio_key: "t38018328")
      t.rdio_get

      assert_equal "USRC11301695",  t.isrc
      assert_equal "Pitbull",       t.artist
      assert_equal "Timber",        t.album
      assert_equal "Timber",        t.name
      assert_equal 204,             t.duration
    end

    it "populates track metadata with an ISRC" do
    end
  end

  context "Spotify" do
    it "populates track metadata for an spotify_id" do
    end

    it "populates track metadata for an ISRC" do
    end
  end
end
