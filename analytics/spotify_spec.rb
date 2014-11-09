require_relative "./analytics_helper"

class Analytics; end

describe User do
  it "loads fixtures" do
    Dir["analytics/*.json"].each do |path|
      values = JSON.parse(File.read(path))
      values.reject! { |k,v| ["uuid", "created_at", "updated_at"].include? k }
      values["playlists"] = Sequel.pg_json(values["playlists"])
      User.create(values)
    end

    assert_equal 3, User.count
    assert_equal 0, Track.count
  end

  it "processes playlist JSON" do
    User.all.each do |user|
      user.save_tracks!
    end
  end

  it "asserts database counts" do
    assert_equal 424, Track.count

    assert_equal 0,   Track.where(key: nil).count
    assert_equal 0,   Track.where(name: nil).count
    assert_equal 0,   Track.where(artist: nil).count
    assert_equal 0,   Track.where(album: nil).count
    assert_equal 0,   Track.where(duration: nil).count
    assert_equal 0,   Track.where(isrcs: nil).count

    assert_equal 0,   Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 0"].count
    assert_equal 399, Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 1"].count
    assert_equal 24,  Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 2"].count
    assert_equal 0,   Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 3"].count
    assert_equal 1,   Track.db["SELECT * FROM tracks WHERE array_length(isrcs,1) = 4"].count
  end
end

# describe Analytics do
#   context "processes entire dataset" do
#     it "turns User.playlist JSON collection into Track objects" do
#       isrcs = []

#       User.all.each do |user|
#         puts JSON.pretty_generate(user.values)
#         puts "\n\n\n\n\n"
#         isrcs += user.playlists_isrcs
#         # user.save_tracks!
#       end

#       assert_equal 444, isrcs.uniq.count
#     end

#     xit "matches and saves spotify_id for every Track" do
#       Track.all.each do |track|
#         track.match_spotify!
#       end
#     end
#   end

#   context "validates entire dataset" do
#     it "asserts database counts" do
#       assert_equal 3,   User.all.count
#       assert_equal 536, Track.all.count

#       assert_equal 0,   Track.where(rdio_key: nil).count
#       assert_equal 0,   Track.where(name: nil).count
#       assert_equal 0,   Track.where(artist: nil).count
#       assert_equal 0,   Track.where(album: nil).count
#       assert_equal 0,   Track.where(duration: nil).count
#       assert_equal 1,   Track.where(isrc: nil).count
#       assert_equal 29,  Track.where(spotify_id: nil).count
#     end
#   end

#   context "explores missing data" do
#     it "debugs missing rdio ISRC" do
#     end

#     it "debugs missing spotify_ids" do
#       Track.where(spotify_id: nil).each do |track|
#         # puts track.get_rdio.inspect
#         # r = track.search_spotify
#         # puts r.inspect
#         # track.match_spotify!
#         # track.get_rdio!
#         # puts track.match_by_total_edit_distance.inspect
#       end
#     end
#   end

#   context "compares matching strategies" do
#   end

#   context "tricky ISRCs" do
#     # {:isrc=>"GBZN81300014", :artist=>"CHVRCHES", :album=>"The Bones Of What You Believe (Special Edition)", :name=>"The Mother We Share", :duration=>190}
#     # {:isrc=>"DEAR41185973", :artist=>"Mantra Mindware", :album=>"Forgivness", :name=>"Isrc", :duration=>428}
#     # {:isrc=>"FRY680300093", :artist=>"Alain Chamfort", :album=>"Le Plaisir", :name=>"Titre 14 (indexé avec code ISRC)", :duration=>54}

#     # {:isrc=>"GBUM71300113", :artist=>"Haim", :album=>"Days Are Gone", :name=>"Falling", :duration=>257}
#     # {:isrc=>"USSM11300646", :artist=>"Haim", :album=>"Falling", :name=>"Falling", :duration=>258}
#     # {:isrc=>"USSM11300646", :artist=>"Haim", :album=>"Days Are Gone", :name=>"Falling", :duration=>257}

#     # {:isrc=>"GBCEL1300216", :artist=>"Washed Out", :album=>"Paracosm", :name=>"It All Feels Right", :duration=>245}
#     # {:isrc=>"USSUB1305502", :artist=>"Washed Out", :album=>"It All Feels Right", :name=>"It All Feels Right", :duration=>245}
#     # {:isrc=>"USSUB1305502", :artist=>"Washed Out", :album=>"Paracosm", :name=>"It All Feels Right", :duration=>245}

#     # {:isrc=>"USSM11304478", :artist=>"Haim", :album=>"Days Are Gone", :name=>"The Wire", :duration=>245}
#     # {:isrc=>"GBUM71304660", :artist=>"Haim", :album=>"Days Are Gone (Deluxe Edition)", :name=>"The Wire", :duration=>245}
#     # {:isrc=>"GBUM71304660", :artist=>"Haim", :album=>"Days Are Gone", :name=>"The Wire", :duration=>245}
#   end

# end
