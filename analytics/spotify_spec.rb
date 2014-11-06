require_relative "./analytics_helper"

describe User do
  it "asserts analytics data" do
    num_tracks = 0
    isrcs = []

    User.each do |user|
      user.playlists.each do |kind, lists|
        lists.each do |list|
          list['tracks'].each do |track|
            num_tracks += 1
            isrcs += track["isrcs"]

            assert track["isrcs"].length > 0
          end
        end
      end

      user.save_tracks!
    end

    assert_equal 3,   User.count
    assert_equal 444, Track.count
    assert_equal 662, num_tracks
    assert_equal 710, isrcs.length
    assert_equal 444, isrcs.uniq.length
  end

  xit "looks up every ISRC on spotify" do
    Track.each do |track|
      track.search_spotify!
    end

    assert_equal 28, Track.where(spotify_id: nil).count
  end

  xit "does something about multiple ISRC search results" do
  end

  it "tries a fuzzy search" do
    Track.where(spotify_id: nil).each do |track|
      track.fuzzy_search_spotify
    end
  end
end
