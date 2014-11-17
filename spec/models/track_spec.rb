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

  context "with a JSON snapshot of Rdio playlists and no Spotify search results" do
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

  context "with a JSON snapshot of Rdio playlists and Spotify search results" do
    before do
      expect(RdioClient).to receive(:get_user) {
        { "key" => "s3385", "url" => "/people/nzoschke/" }
      }

      expect(RdioClient).to receive(:get_playlists) {
        {
          "favorites"=>[], "subscribed"=>[], "collab"=>[], "owned"=>[{"ownerKey"=>"s3385", "name"=>"April Fools!", "baseIcon"=>"album/3/3/f/0000000000029f33/5/square-200.jpg", "url"=>"/people/nzoschke/playlists/8763814/April_Fools!/", "ownerIcon"=>"user/9/3/d/0000000000000d39/1/square-100.jpg", "ownerUrl"=>"/people/nzoschke/", 
          "tracks"=>[
            {"album"=>"The Bends (Collector's Edition)", "isrcs"=>["GBAYE9400673"], "name"=>"The Trickster", "artist"=>"Radiohead", "key"=>"t2062973", "duration"=>282},
            {"album"=>"Weird Day", "isrcs"=>["USLZJ1138076"], "name"=>"Weird Day (Guau Remix)", "artist"=>"Destroyers", "key"=>"t9923014", "duration"=>348}
          ],
          "lastUpdated"=>1396472068.0, "shortUrl"=>"http://rd.io/x/QFJ7L8bm9A/", "length"=>12, "key"=>"p8763814", "owner"=>"Noah Zoschke", "embedUrl"=>"https://rd.io/e/QFJ7L8bm9A/", "type"=>"p", "icon"=>"http://m.rdio.com/_is/?aid=133019-3,24096-1,138122-0,355264-0,132988-0,171827-5,240001-0,238686-0,203664-0&w=200&h=200"}]}
      }

      expect(UserPlaylistsWorker).to receive(:perform_async) {}

      expect(SpotifyClient).to receive(:search_by_isrcs).and_return(
        [
          {"album"=>{"album_type"=>"album", "available_markets"=>["AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "IE", "IS", "IT", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "RO", "SE", "SG", "SI", "SK", "SV", "TR", "TW", "US", "UY"], "external_urls"=>{"spotify"=>"https://open.spotify.com/album/1P1LYaTMV1LnDiHA3LOows"}, "href"=>"https://api.spotify.com/v1/albums/1P1LYaTMV1LnDiHA3LOows", "id"=>"1P1LYaTMV1LnDiHA3LOows", "images"=>[{"height"=>640, "url"=>"https://i.scdn.co/image/33123841106ea5f8af86a343131132bf0b67a0a4", "width"=>640}, {"height"=>300, "url"=>"https://i.scdn.co/image/29c1ef141964af106d8dafa233ede91c1062829c", "width"=>300}, {"height"=>64, "url"=>"https://i.scdn.co/image/a199788667689b041113eabd494a27e3a1d41da3", "width"=>64}], "name"=>"The Bends [Collectors Edition]", "type"=>"album", "uri"=>"spotify:album:1P1LYaTMV1LnDiHA3LOows"}, "artists"=>[{"external_urls"=>{"spotify"=>"https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"}, "href"=>"https://api.spotify.com/v1/artists/4Z8W4fKeB5YxbusRsdQVPb", "id"=>"4Z8W4fKeB5YxbusRsdQVPb", "name"=>"Radiohead", "type"=>"artist", "uri"=>"spotify:artist:4Z8W4fKeB5YxbusRsdQVPb"}], "available_markets"=>["AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "IE", "IS", "IT", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "RO", "SE", "SG", "SI", "SK", "SV", "TR", "TW", "US", "UY"], "disc_number"=>2, "duration_ms"=>282293, "explicit"=>false, "external_ids"=>{"isrc"=>"GBAYE9400673"}, "external_urls"=>{"spotify"=>"https://open.spotify.com/track/5ikIFKeCuGCKX9foh8ToyN"}, "href"=>"https://api.spotify.com/v1/tracks/5ikIFKeCuGCKX9foh8ToyN", "id"=>"5ikIFKeCuGCKX9foh8ToyN", "name"=>"The Trickster", "popularity"=>43, "preview_url"=>"https://p.scdn.co/mp3-preview/0fa361fd804eb372d15e28e60c31e34a1b12035a", "track_number"=>1, "type"=>"track", "uri"=>"spotify:track:5ikIFKeCuGCKX9foh8ToyN"}, 
          {"album"=>{"album_type"=>"single", "available_markets"=>["AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "IE", "IS", "IT", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "RO", "SE", "SG", "SI", "SK", "SV", "TR", "TW", "US", "UY"], "external_urls"=>{"spotify"=>"https://open.spotify.com/album/3SROeog5VviGOdcuZDTirh"}, "href"=>"https://api.spotify.com/v1/albums/3SROeog5VviGOdcuZDTirh", "id"=>"3SROeog5VviGOdcuZDTirh", "images"=>[{"height"=>640, "url"=>"https://i.scdn.co/image/125f1a35dd655f09cc7fc0ed47264add8e3b82de", "width"=>640}, {"height"=>300, "url"=>"https://i.scdn.co/image/577f7b1354a547e0eff3e675718d4cae0eb63ce9", "width"=>300}, {"height"=>64, "url"=>"https://i.scdn.co/image/461e6c55cfe3db61bc24b5342e03825dfd959154", "width"=>64}], "name"=>"My Iron Lung", "type"=>"album", "uri"=>"spotify:album:3SROeog5VviGOdcuZDTirh"}, "artists"=>[{"external_urls"=>{"spotify"=>"https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb"}, "href"=>"https://api.spotify.com/v1/artists/4Z8W4fKeB5YxbusRsdQVPb", "id"=>"4Z8W4fKeB5YxbusRsdQVPb", "name"=>"Radiohead", "type"=>"artist", "uri"=>"spotify:artist:4Z8W4fKeB5YxbusRsdQVPb"}], "available_markets"=>["AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "IE", "IS", "IT", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "RO", "SE", "SG", "SI", "SK", "SV", "TR", "TW", "US", "UY"], "disc_number"=>1, "duration_ms"=>280466, "explicit"=>false, "external_ids"=>{"isrc"=>"GBAYE9400673"}, "external_urls"=>{"spotify"=>"https://open.spotify.com/track/2fLiisZYOeVcHa5IGFLyxb"}, "href"=>"https://api.spotify.com/v1/tracks/2fLiisZYOeVcHa5IGFLyxb", "id"=>"2fLiisZYOeVcHa5IGFLyxb", "name"=>"The Trickster", "popularity"=>18, "preview_url"=>"https://p.scdn.co/mp3-preview/987f09fc813857eb3d63862572468a111e833d0a", "track_number"=>2, "type"=>"track", "uri"=>"spotify:track:2fLiisZYOeVcHa5IGFLyxb"}
        ],
        []
      )

      @user = User.find_or_create_by_credentials({ "token" => "oauth_token", "secret" => "oauth_secret" })
      @user.save_playlists!
    end

    it "saves Tracks with Spotify metadata" do
      @user.match_tracks!
      assert_equal 2, Track.count

      t1 = Track.all[0]
      t2 = Track.all[1]

      assert_equal "5ikIFKeCuGCKX9foh8ToyN",          t1.spotify_id
      assert_equal "The Bends [Collectors Edition]",  t1.spotify_album

      assert_equal nil, t2.spotify_id
    end

    it "creates a Spotify playlist" do
      @user.match_tracks!
      @user.spotify_token = ENV['SPOTIFY_USER_TOKEN']


      playlists = SpotifyClient.get_playlists(@user)
      assert_equal(
        {"href"=>"https://api.spotify.com/v1/users/mixable.net/playlists?offset=0&limit=20", "items"=>[{"collaborative"=>false, "external_urls"=>{"spotify"=>"http://open.spotify.com/user/mixable.net/playlist/3w9FqIAuzAx2TJlFHFjdEv"}, "href"=>"https://api.spotify.com/v1/users/mixable.net/playlists/3w9FqIAuzAx2TJlFHFjdEv", "id"=>"3w9FqIAuzAx2TJlFHFjdEv", "images"=>[], "name"=>"Cool!", "owner"=>{"external_urls"=>{"spotify"=>"http://open.spotify.com/user/mixable.net"}, "href"=>"https://api.spotify.com/v1/users/mixable.net", "id"=>"mixable.net", "type"=>"user", "uri"=>"spotify:user:mixable.net"}, "public"=>false, "tracks"=>{"href"=>"https://api.spotify.com/v1/users/mixable.net/playlists/3w9FqIAuzAx2TJlFHFjdEv/tracks", "total"=>2}, "type"=>"playlist", "uri"=>"spotify:user:mixable.net:playlist:3w9FqIAuzAx2TJlFHFjdEv"}], "limit"=>20, "next"=>nil, "offset"=>0, "previous"=>nil, "total"=>1},
        playlists
      )

      playlist = SpotifyClient.create_or_update_playlist(@user, "Cool!",
        [
          "spotify:track:4iV5W9uYEdYUVa79Axb7Rh",
          "spotify:track:1301WleyT98MSxVHPZCA6M"
        ]
      )

      assert_equal "3w9FqIAuzAx2TJlFHFjdEv", playlist["id"]
      assert_equal 2, playlist["tracks"]["total"]

      e = assert_raises OAuth2::Error do
        SpotifyClient.create_or_update_playlist(@user, "Cool!",
          [
            "spotify:local:Rinocerose:mixable001:Cubicle:193",
          ]
        )
      end

      assert e.message =~ /JSON body contains an invalid track uri: spotify:local/
    end
  end
end
