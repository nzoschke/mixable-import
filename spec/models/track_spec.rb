require "spec_helper"

describe Track do
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

  xit "gets rdio and spotify metadata" do
    t = Track.create(rdio_key: "t3160205", spotify_id: "2wEHxTBxLJk3vYzyW6dsAU")
    assert_equal({ :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box (Live)", :duration=>337 }, t.get_rdio)
    assert_equal({ :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box - Live", :duration=>337 }, t.get_spotify)
  end

  # # TODO: test matchers via stubs/mocks
  # it "matches an rdio_key to a spotify_id by first result" do
  #   t = Track[key: "t3160205"]
  #   m = t.match_by_first_result
  #   assert_equal({ "4XuHSTkpToHdZgxp0xar6i" => { :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box - Live", :duration=>337 } }, m)
  # end

  # it "matches an rdio_key to a spotify_id by total edit distance" do
  #   t = Track[key: "t3160205"]
  #   m = t.match_by_total_edit_distance
  #   assert_equal({ "4XuHSTkpToHdZgxp0xar6i" => { :isrc=>"GBARA9800069", :artist=>"Portishead", :album=>"Roseland NYC Live", :name=>"Glory Box - Live", :duration=>337 } }, m)
  # end
end
