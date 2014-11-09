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

    # TODO: How to query into the JSON?!
    # User.db["SELECT * FROM users WHERE 'April Fools!' IN (SELECT value->>'name' FROM json_array_elements(playlists))"].all.inspect
    # Sequel::DatabaseError:
    #   PG::InvalidParameterValue: ERROR:  cannot call json_array_elements on a non-array
  end

  context "with saved JSON snapshot of Rdio playlists" do
    before do
      @user.playlists = {"favorites"=>[], "subscribed"=>[], "collab"=>[], "owned"=>[{"ownerKey"=>"s3385", "name"=>"April Fools!", "baseIcon"=>"album/3/3/f/0000000000029f33/5/square-200.jpg", "url"=>"/people/nzoschke/playlists/8763814/April_Fools!/", "ownerIcon"=>"user/9/3/d/0000000000000d39/1/square-100.jpg", "ownerUrl"=>"/people/nzoschke/", "tracks"=>[{"album"=>"The Bends (Collector's Edition)", "isrcs"=>["GBAYE9400673"], "name"=>"The Trickster", "artist"=>"Radiohead", "key"=>"t2062973", "duration"=>282}, {"album"=>"Visiter", "isrcs"=>["USJMZ0800027"], "name"=>"Fools", "artist"=>"The Dodos", "key"=>"t301628", "duration"=>282}, {"album"=>"Rooms Filled With Light", "isrcs"=>["TCABM1364901", "USAT21101923"], "name"=>"Deconstruction", "artist"=>"Fanfarlo", "key"=>"t15739271", "duration"=>296}, {"album"=>"Lovefool", "isrcs"=>["USA370999316"], "name"=>"Lovefool [Radio Edit]", "artist"=>"Distant Soundz Feat Rozalla", "key"=>"t1694801", "duration"=>193}, {"album"=>"Neon Golden", "isrcs"=>["GBCEL0500643"], "name"=>"One With the Freaks", "artist"=>"The Notwist", "key"=>"t1695241", "duration"=>218}, {"album"=>"The Moon & Antarctica", "isrcs"=>["USSM10004739"], "name"=>"Perfect Disguise", "artist"=>"Modest Mouse", "key"=>"t2917864", "duration"=>161}, {"album"=>"Go Forth", "isrcs"=>["USA560311898"], "name"=>"Daily Dares", "artist"=>"Les Savy Fav", "key"=>"t1750784", "duration"=>192}, {"album"=>"Americana", "isrcs"=>["USSM19804363"], "name"=>"The Kids Aren't Alright", "artist"=>"The Offspring", "key"=>"t2899086", "duration"=>179}, {"album"=>"Solid Gold Hits", "isrcs"=>["USCA20501226", "USCA20501217"], "name"=>"Sabotage (Digitally Remastered 2005)", "artist"=>"Beastie Boys", "key"=>"t2458109", "duration"=>178}, {"album"=>"Body Talk", "isrcs"=>["SEWKZ1000122"], "name"=>"U Should Know Better", "artist"=>"Robyn", "key"=>"t6896002", "duration"=>241}, {"album"=>"Weird Day", "isrcs"=>["USLZJ1138076"], "name"=>"Weird Day (Guau Remix)", "artist"=>"Destroyers", "key"=>"t9923014", "duration"=>348}, {"album"=>"I Care Because You Do", "isrcs"=>["GBBPW9500097", "USSI10100106"], "name"=>"Come On You Slags!", "artist"=>"Aphex Twin", "key"=>"t4365405", "duration"=>344}], "lastUpdated"=>1396472068.0, "shortUrl"=>"http://rd.io/x/QFJ7L8bm9A/", "length"=>12, "key"=>"p8763814", "owner"=>"Noah Zoschke", "embedUrl"=>"https://rd.io/e/QFJ7L8bm9A/", "type"=>"p", "icon"=>"http://m.rdio.com/_is/?aid=133019-3,24096-1,138122-0,355264-0,132988-0,171827-5,240001-0,238686-0,203664-0&w=200&h=200"}]}
    end

    it "collects all ISRCs" do
      isrcs = ["GBAYE9400673", "USJMZ0800027", "TCABM1364901", "USAT21101923", "USA370999316", "GBCEL0500643", "USSM10004739", "USA560311898", "USSM19804363", "USCA20501226", "USCA20501217", "SEWKZ1000122", "USLZJ1138076", "GBBPW9500097", "USSI10100106"]
      assert_equal isrcs, @user.playlists_isrcs
      assert_equal 15, @user.playlists_isrcs.count
    end

    it "creates Tracks" do
      @user.save_tracks!
      assert_equal 12, Track.count

      # TODO: move this array malarkey to track spec and make it work better
      r = Track.where("isrcs @> '{USCA20501217}'")
      assert_equal 1, r.count
      assert_equal ["USCA20501226", "USCA20501217"], r.first.isrcs

      r = Track.where("'USCA20501217' = ANY(isrcs)")
      assert_equal 1, r.count
      assert_equal ["USCA20501226", "USCA20501217"], r.first.isrcs

      ds = Track.db["SELECT *, UNNEST(isrcs) AS isrc FROM tracks"]
      assert_equal 15, ds.count
    end
  end
end
