require "spec_helper"

describe User do
  before do
    @credentials = { "token" => ENV['RDIO_USER_TOKEN'], "secret" => ENV['RDIO_USER_SECRET'] }
    @user = User.find_or_create_by_credentials @credentials
  end

  it "creates a new user by Rdio OAuth credentials" do
    @user.delete

    u = User.find_or_create_by_credentials @credentials

    assert u.uuid
    assert_equal "s3385", u.key
    assert_equal "/people/nzoschke/", u.url
    assert_equal ENV['RDIO_USER_TOKEN'], u.token
    assert_equal ENV['RDIO_USER_SECRET'], u.secret
  end

  it "finds an existing user by Rdio OAuth credentials" do
    u2 = User.find_or_create_by_credentials @credentials
    assert_equal @user.uuid, u2.uuid
  end

  it "saves a JSON snapshot of Rdio playlists" do
    @user.save_playlists!
    assert_equal "April Fools!", @user.playlists["owned"][1]["name"]
    assert_equal 85, @user.tracks_total
    assert_equal 0,  @user.tracks_processed

    # TODO: How to query into the JSON?!
    # User.db["SELECT * FROM users WHERE 'April Fools!' IN (SELECT value->>'name' FROM json_array_elements(playlists))"].all.inspect
    # Sequel::DatabaseError:
    #   PG::InvalidParameterValue: ERROR:  cannot call json_array_elements on a non-array
  end

  context "with saved JSON snapshot of Rdio playlists" do
    before do
      expect(RdioClient).to receive(:get_playlists) {
        {"favorites"=>[], "subscribed"=>[], "collab"=>[], "owned"=>[{"ownerKey"=>"s3385", "name"=>"April Fools!", "baseIcon"=>"album/3/3/f/0000000000029f33/5/square-200.jpg", "url"=>"/people/nzoschke/playlists/8763814/April_Fools!/", "ownerIcon"=>"user/9/3/d/0000000000000d39/1/square-100.jpg", "ownerUrl"=>"/people/nzoschke/", "tracks"=>[{"album"=>"The Bends (Collector's Edition)", "isrcs"=>["GBAYE9400673"], "name"=>"The Trickster", "artist"=>"Radiohead", "key"=>"t2062973", "duration"=>282}, {"album"=>"Visiter", "isrcs"=>["USJMZ0800027"], "name"=>"Fools", "artist"=>"The Dodos", "key"=>"t301628", "duration"=>282}, {"album"=>"Rooms Filled With Light", "isrcs"=>["TCABM1364901", "USAT21101923"], "name"=>"Deconstruction", "artist"=>"Fanfarlo", "key"=>"t15739271", "duration"=>296}, {"album"=>"Lovefool", "isrcs"=>["USA370999316"], "name"=>"Lovefool [Radio Edit]", "artist"=>"Distant Soundz Feat Rozalla", "key"=>"t1694801", "duration"=>193}, {"album"=>"Neon Golden", "isrcs"=>["GBCEL0500643"], "name"=>"One With the Freaks", "artist"=>"The Notwist", "key"=>"t1695241", "duration"=>218}, {"album"=>"The Moon & Antarctica", "isrcs"=>["USSM10004739"], "name"=>"Perfect Disguise", "artist"=>"Modest Mouse", "key"=>"t2917864", "duration"=>161}, {"album"=>"Go Forth", "isrcs"=>["USA560311898"], "name"=>"Daily Dares", "artist"=>"Les Savy Fav", "key"=>"t1750784", "duration"=>192}, {"album"=>"Americana", "isrcs"=>["USSM19804363"], "name"=>"The Kids Aren't Alright", "artist"=>"The Offspring", "key"=>"t2899086", "duration"=>179}, {"album"=>"Solid Gold Hits", "isrcs"=>["USCA20501226", "USCA20501217"], "name"=>"Sabotage (Digitally Remastered 2005)", "artist"=>"Beastie Boys", "key"=>"t2458109", "duration"=>178}, {"album"=>"Body Talk", "isrcs"=>["SEWKZ1000122"], "name"=>"U Should Know Better", "artist"=>"Robyn", "key"=>"t6896002", "duration"=>241}, {"album"=>"Weird Day", "isrcs"=>["USLZJ1138076"], "name"=>"Weird Day (Guau Remix)", "artist"=>"Destroyers", "key"=>"t9923014", "duration"=>348}, {"album"=>"I Care Because You Do", "isrcs"=>["GBBPW9500097", "USSI10100106"], "name"=>"Come On You Slags!", "artist"=>"Aphex Twin", "key"=>"t4365405", "duration"=>344}], "lastUpdated"=>1396472068.0, "shortUrl"=>"http://rd.io/x/QFJ7L8bm9A/", "length"=>12, "key"=>"p8763814", "owner"=>"Noah Zoschke", "embedUrl"=>"https://rd.io/e/QFJ7L8bm9A/", "type"=>"p", "icon"=>"http://m.rdio.com/_is/?aid=133019-3,24096-1,138122-0,355264-0,132988-0,171827-5,240001-0,238686-0,203664-0&w=200&h=200"}]}
      }

      expect(UserPlaylistsWorker).to receive(:perform_async) {}

      @user.save_playlists!
    end

    it "creates and matches Tracks" do
      assert_equal 12, @user.tracks_total
      assert_equal 0,  @user.tracks_processed
      assert_equal 0,  Track.count

      @user.match_tracks!

      assert_equal 12, @user.tracks_processed
      assert_equal 12, Track.count
    end
  end

  context "fixtures" do
    before do
      Dir["analytics/*.json"].each do |path|
        values = JSON.parse(File.read(path))
        values.reject! { |k,v| ["uuid", "created_at", "updated_at"].include? k }
        values["playlists"] = Sequel.pg_json(values["playlists"])
        User.create(values)
      end
    end

    it "analytics" do
      
    end
  end
end
