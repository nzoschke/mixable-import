require "spec_helper"

describe Track do
  context "with unauthorized Rdio and Spotify API access" do
    it "gets rdio metadata" do
      track = Track.create(rdio_key: "t3160205")
      t = RdioClient.get_track(track)
      assert_equal(
        {"radioKey"=>"sr3160205", "baseIcon"=>"album/7/3/e/000000000003ee37/1/square-200.jpg", "canDownloadAlbumOnly"=>false, "radio"=>{"type"=>"sr", "key"=>"sr3160205"}, "artistUrl"=>"/artist/Portishead/", "duration"=>337, "album"=>"Roseland NYC Live", "isrcs"=>["GBARA9800069"], "isClean"=>false, "albumUrl"=>"/artist/Portishead/album/Roseland_NYC_Live/", "shortUrl"=>"http://rd.io/x/QityZ84/", "albumArtist"=>"Portishead", "canStream"=>true, "embedUrl"=>"https://rd.io/e/QityZ84/", "type"=>"t", "gridIcon"=>"http://rdiodynimages3-a.akamaihd.net/?l=a257591-1%3Aboxblur%2810%25%2C10%25%29%3Ba257591-1%3Aprimary%280.65%29%3B%240%3Aoverlay%28%241%29%3Ba257591-1%3Apad%2850%25%29%3B%242%3Aoverlay%28%243%29", "price"=>"None", "trackNum"=>8, "albumArtistKey"=>"r138607", "key"=>"t3160205", "icon"=>"http://img00.cdn2-rdio.com/album/7/3/e/000000000003ee37/1/square-200.jpg", "canSample"=>true, "name"=>"Glory Box (Live)", "isExplicit"=>false, "artist"=>"Portishead", "url"=>"/artist/Portishead/album/Roseland_NYC_Live/track/Glory_Box_(Live)/", "icon400"=>"http://img02.cdn2-rdio.com/album/7/3/e/000000000003ee37/1/square-400.jpg", "artistKey"=>"r138607", "canDownload"=>false, "length"=>1, "canTether"=>true, "albumKey"=>"a257591"},
        t
      )
    end

    it "gets spotify metadata" do
      track = Track.create(spotify_id: "2wEHxTBxLJk3vYzyW6dsAU")
      t = SpotifyClient.get_track(track)
      assert_equal(
        {"album"=>{"album_type"=>"album", "available_markets"=>["CA", "MX", "US"], "external_urls"=>{"spotify"=>"https://open.spotify.com/album/1Td5bSMxDrTIDAvxJQIo5t"}, "href"=>"https://api.spotify.com/v1/albums/1Td5bSMxDrTIDAvxJQIo5t", "id"=>"1Td5bSMxDrTIDAvxJQIo5t", "images"=>[{"height"=>635, "url"=>"https://i.scdn.co/image/aac676c1ec03352b4aa8232e1c93ae51f8dcec71", "width"=>640}, {"height"=>297, "url"=>"https://i.scdn.co/image/7d38a3c613456794eecd91db9d7985e25de3af9f", "width"=>300}, {"height"=>63, "url"=>"https://i.scdn.co/image/18474e1e0760b152b1648a82ff3955084a25fe02", "width"=>64}], "name"=>"Roseland NYC Live", "type"=>"album", "uri"=>"spotify:album:1Td5bSMxDrTIDAvxJQIo5t"}, "artists"=>[{"external_urls"=>{"spotify"=>"https://open.spotify.com/artist/6liAMWkVf5LH7YR9yfFy1Y"}, "href"=>"https://api.spotify.com/v1/artists/6liAMWkVf5LH7YR9yfFy1Y", "id"=>"6liAMWkVf5LH7YR9yfFy1Y", "name"=>"Portishead", "type"=>"artist", "uri"=>"spotify:artist:6liAMWkVf5LH7YR9yfFy1Y"}], "available_markets"=>["CA", "MX", "US"], "disc_number"=>1, "duration_ms"=>337153, "explicit"=>false, "external_ids"=>{"isrc"=>"GBARA9800069"}, "external_urls"=>{"spotify"=>"https://open.spotify.com/track/2wEHxTBxLJk3vYzyW6dsAU"}, "href"=>"https://api.spotify.com/v1/tracks/2wEHxTBxLJk3vYzyW6dsAU", "id"=>"2wEHxTBxLJk3vYzyW6dsAU", "name"=>"Glory Box - Live", "popularity"=>53, "preview_url"=>"https://p.scdn.co/mp3-preview/83852b88c761145544fb38d6c94fda508ec3e7a6", "track_number"=>8, "type"=>"track", "uri"=>"spotify:track:2wEHxTBxLJk3vYzyW6dsAU"},
        t
      )
    end

    it "matches an rdio track to a spotify track" do
      t = Track.create(rdio_key: "t3160205", rdio_isrcs: "{GBARA9800069}", :rdio_artist=>"Portishead", :rdio_album=>"Roseland NYC Live", :rdio_name=>"Glory Box (Live)", :rdio_duration=>337)
      t.match_spotify!

      assert_equal "Glory Box - Live",  t.spotify_name
      assert_equal "Roseland NYC Live", t.spotify_album
      assert_equal "Portishead",        t.spotify_artist
      assert_equal 337153,              t.spotify_duration_ms
      assert_equal "{GBARA9800069}",    t.spotify_isrcs

      assert_equal "GBARA9800069",      t.isrc
    end
  end

  context "with saved JSON snapshot of Rdio playlists and no Spotify search results" do
    before do
      expect(RdioClient).to receive(:get_user) {
        { "key" => "s3385", "url" => "/people/nzoschke/" }
      }

      expect(RdioClient).to receive(:get_playlists) {
        {"favorites"=>[], "subscribed"=>[], "collab"=>[], "owned"=>[{"ownerKey"=>"s3385", "name"=>"April Fools!", "baseIcon"=>"album/3/3/f/0000000000029f33/5/square-200.jpg", "url"=>"/people/nzoschke/playlists/8763814/April_Fools!/", "ownerIcon"=>"user/9/3/d/0000000000000d39/1/square-100.jpg", "ownerUrl"=>"/people/nzoschke/", "tracks"=>[{"album"=>"The Bends (Collector's Edition)", "isrcs"=>["GBAYE9400673"], "name"=>"The Trickster", "artist"=>"Radiohead", "key"=>"t2062973", "duration"=>282}, {"album"=>"Visiter", "isrcs"=>["USJMZ0800027"], "name"=>"Fools", "artist"=>"The Dodos", "key"=>"t301628", "duration"=>282}, {"album"=>"Rooms Filled With Light", "isrcs"=>["TCABM1364901", "USAT21101923"], "name"=>"Deconstruction", "artist"=>"Fanfarlo", "key"=>"t15739271", "duration"=>296}, {"album"=>"Lovefool", "isrcs"=>["USA370999316"], "name"=>"Lovefool [Radio Edit]", "artist"=>"Distant Soundz Feat Rozalla", "key"=>"t1694801", "duration"=>193}, {"album"=>"Neon Golden", "isrcs"=>["GBCEL0500643"], "name"=>"One With the Freaks", "artist"=>"The Notwist", "key"=>"t1695241", "duration"=>218}, {"album"=>"The Moon & Antarctica", "isrcs"=>["USSM10004739"], "name"=>"Perfect Disguise", "artist"=>"Modest Mouse", "key"=>"t2917864", "duration"=>161}, {"album"=>"Go Forth", "isrcs"=>["USA560311898"], "name"=>"Daily Dares", "artist"=>"Les Savy Fav", "key"=>"t1750784", "duration"=>192}, {"album"=>"Americana", "isrcs"=>["USSM19804363"], "name"=>"The Kids Aren't Alright", "artist"=>"The Offspring", "key"=>"t2899086", "duration"=>179}, {"album"=>"Solid Gold Hits", "isrcs"=>["USCA20501226", "USCA20501217"], "name"=>"Sabotage (Digitally Remastered 2005)", "artist"=>"Beastie Boys", "key"=>"t2458109", "duration"=>178}, {"album"=>"Body Talk", "isrcs"=>["SEWKZ1000122"], "name"=>"U Should Know Better", "artist"=>"Robyn", "key"=>"t6896002", "duration"=>241}, {"album"=>"Weird Day", "isrcs"=>["USLZJ1138076"], "name"=>"Weird Day (Guau Remix)", "artist"=>"Destroyers", "key"=>"t9923014", "duration"=>348}, {"album"=>"I Care Because You Do", "isrcs"=>["GBBPW9500097", "USSI10100106"], "name"=>"Come On You Slags!", "artist"=>"Aphex Twin", "key"=>"t4365405", "duration"=>344}], "lastUpdated"=>1396472068.0, "shortUrl"=>"http://rd.io/x/QFJ7L8bm9A/", "length"=>12, "key"=>"p8763814", "owner"=>"Noah Zoschke", "embedUrl"=>"https://rd.io/e/QFJ7L8bm9A/", "type"=>"p", "icon"=>"http://m.rdio.com/_is/?aid=133019-3,24096-1,138122-0,355264-0,132988-0,171827-5,240001-0,238686-0,203664-0&w=200&h=200"}]}
      }

      expect(UserPlaylistsWorker).to receive(:perform_async) {}

      expect(SpotifyClient).to receive(:search_by_isrcs).at_most(12).times { [] }

      @user = User.find_or_create_by_credentials({ "token" => "oauth_token", "secret" => "oauth_secret" })
      @user.save_playlists!
    end

    it "saves Tracks with Rdio metadata" do
      assert_equal 0, Track.count
      @user.match_tracks!
      assert_equal 12, Track.count
    end

    it "queries Tracks with Postgres array syntaxes" do
      @user.match_tracks!

      r = Track.where("rdio_isrcs @> '{USCA20501217}'")
      assert_equal 1, r.count
      assert_equal ["USCA20501226", "USCA20501217"], r.first.rdio_isrcs

      r = Track.where("'USCA20501217' = ANY(rdio_isrcs)")
      assert_equal 1, r.count
      assert_equal ["USCA20501226", "USCA20501217"], r.first.rdio_isrcs

      ds = Track.db["SELECT *, UNNEST(rdio_isrcs) AS isrc FROM tracks"]
      assert_equal 15, ds.count
    end
  end
end
