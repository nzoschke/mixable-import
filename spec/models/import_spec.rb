require "spec_helper"

describe Import do
  before do
    @user = User.create(rdio_playlists: Sequel.pg_json({
      "collab"      => [],
      "subscribed"  => [],
      "favorites"   => [],
      "owned"       => [{ "name"=>"April Fools!", "tracks"=>[ {"album"=>"The Bends (Collector's Edition)", "isrcs"=>["GBAYE9400673"], "name"=>"The Trickster", "artist"=>"Radiohead", "key"=>"t2062973", "duration"=>282}, ], "length"=>1, "key"=>"p8763814" }]
    }))

    @track = Track.create(rdio_key: "t2062973")
  end

  it "doesn't start if Rdio track matching is in progress" do
    @track.delete

    e = assert_raises ImportError do
      @user.start_spotify_import!
    end

    assert_equal "Track matching in progress", e.message
  end

  it "doesn't start if another import is in progress" do
    @user.start_spotify_import!

    e = assert_raises ImportError do
      @user.start_spotify_import!
    end

    assert_equal "Import in progress", e.message
  end

  it "does start if another import has expired" do
    @user.start_spotify_import!(created_at: Time.now - 120)

    e = assert_raises ImportError do
      @user.start_spotify_import!(created_at: Time.now - 10)
    end
    assert_equal "Import in progress", e.message

    @user.start_spotify_import!(created_at: Time.now)
  end

  it "tracks progress by playlist name and count and track count" do
    i = @user.start_spotify_import!

    assert i[:created_at]
    assert i[:updated_at]

    assert_equal 1,   i[:spotify_playlists]["total"]
    assert_equal 0,   i[:spotify_playlists]["added"]
    assert_equal 0,   i[:spotify_playlists]["processed"]
    assert_equal [],  i[:spotify_playlists]["items"]
  end

end
