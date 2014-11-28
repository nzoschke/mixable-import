require "spec_helper"

describe Endpoints::Playlists do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./docs/schema.json"
  end

  context "Rdio" do
    before do
      @user = User.create(rdio_playlists: Sequel.pg_json({"favorites"=>[], "subscribed"=>[], "collab"=>[], "owned"=>[{"ownerKey"=>"s3385", "name"=>"April Fools!", "baseIcon"=>"album/3/3/f/0000000000029f33/5/square-200.jpg", "url"=>"/people/nzoschke/playlists/8763814/April_Fools!/", "ownerIcon"=>"user/9/3/d/0000000000000d39/1/square-100.jpg", "ownerUrl"=>"/people/nzoschke/", "tracks"=>[{"album"=>"The Bends (Collector's Edition)", "isrcs"=>["GBAYE9400673"], "name"=>"The Trickster", "artist"=>"Radiohead", "key"=>"t2062973", "duration"=>282}, {"album"=>"Visiter", "isrcs"=>["USJMZ0800027"], "name"=>"Fools", "artist"=>"The Dodos", "key"=>"t301628", "duration"=>282}, {"album"=>"Rooms Filled With Light", "isrcs"=>["TCABM1364901", "USAT21101923"], "name"=>"Deconstruction", "artist"=>"Fanfarlo", "key"=>"t15739271", "duration"=>296}, {"album"=>"Lovefool", "isrcs"=>["USA370999316"], "name"=>"Lovefool [Radio Edit]", "artist"=>"Distant Soundz Feat Rozalla", "key"=>"t1694801", "duration"=>193}, {"album"=>"Neon Golden", "isrcs"=>["GBCEL0500643"], "name"=>"One With the Freaks", "artist"=>"The Notwist", "key"=>"t1695241", "duration"=>218}, {"album"=>"The Moon & Antarctica", "isrcs"=>["USSM10004739"], "name"=>"Perfect Disguise", "artist"=>"Modest Mouse", "key"=>"t2917864", "duration"=>161}, {"album"=>"Go Forth", "isrcs"=>["USA560311898"], "name"=>"Daily Dares", "artist"=>"Les Savy Fav", "key"=>"t1750784", "duration"=>192}, {"album"=>"Americana", "isrcs"=>["USSM19804363"], "name"=>"The Kids Aren't Alright", "artist"=>"The Offspring", "key"=>"t2899086", "duration"=>179}, {"album"=>"Solid Gold Hits", "isrcs"=>["USCA20501226", "USCA20501217"], "name"=>"Sabotage (Digitally Remastered 2005)", "artist"=>"Beastie Boys", "key"=>"t2458109", "duration"=>178}, {"album"=>"Body Talk", "isrcs"=>["SEWKZ1000122"], "name"=>"U Should Know Better", "artist"=>"Robyn", "key"=>"t6896002", "duration"=>241}, {"album"=>"Weird Day", "isrcs"=>["USLZJ1138076"], "name"=>"Weird Day (Guau Remix)", "artist"=>"Destroyers", "key"=>"t9923014", "duration"=>348}, {"album"=>"I Care Because You Do", "isrcs"=>["GBBPW9500097", "USSI10100106"], "name"=>"Come On You Slags!", "artist"=>"Aphex Twin", "key"=>"t4365405", "duration"=>344}], "lastUpdated"=>1396472068.0, "shortUrl"=>"http://rd.io/x/QFJ7L8bm9A/", "length"=>12, "key"=>"p8763814", "owner"=>"Noah Zoschke", "embedUrl"=>"https://rd.io/e/QFJ7L8bm9A/", "type"=>"p", "icon"=>"http://m.rdio.com/_is/?aid=133019-3,24096-1,138122-0,355264-0,132988-0,171827-5,240001-0,238686-0,203664-0&w=200&h=200"}]}))
      @env = { "rack.session" => { "uuid" => @user.uuid } }
    end

    describe 'GET /playlists' do
      it 'returns correct status code and conforms to schema' do
        get '/playlists/rdio', {}, @env
        assert_equal 200, last_response.status
        assert_schema_conform
      end
    end

    describe 'POST /playlists' do
      it 'returns correct status code and conforms to schema' do
        header "Content-Type", "application/json"
        post '/playlists/rdio', MultiJson.encode({}), @env

        # TODO: How to define explcitly disabled endpoints in schema?
        assert_equal 403, last_response.status
        e = assert_raises Committee::InvalidResponse do
          assert_schema_conform
        end
        assert e.message =~ /undefined in schema/
      end
    end

    describe 'GET /playlists/:id' do
      it 'returns correct status code and conforms to schema' do
        get "/playlists/rdio/p8763814", {}, @env
        assert_equal 200, last_response.status
        assert_schema_conform
      end
    end

    describe 'PATCH /playlists/:id' do
      it 'returns correct status code and conforms to schema' do
        header "Content-Type", "application/json"
        patch "/playlists/rdio/p8763814", MultiJson.encode({}), @env

        assert_equal 403, last_response.status
        e = assert_raises Committee::InvalidResponse do
          assert_schema_conform
        end
        assert e.message =~ /undefined in schema/
      end
    end

    describe 'DELETE /playlists/:id' do
      it 'returns correct status code and conforms to schema' do
        delete "/playlists/rdio/p8763814", {}, @env

        assert_equal 403, last_response.status
        e = assert_raises Committee::InvalidResponse do
          assert_schema_conform
        end
        assert e.message =~ /undefined in schema/
      end
    end
  end

  context "Spotify" do
    before do
      # Create User with example response from https://developer.spotify.com/web-api/get-list-users-playlists/
      @user = User.create(spotify_playlists: Sequel.pg_json(
        {"href"=>"https://api.spotify.com/v1/users/wizzler/playlists", "items"=>[{"collaborative"=>false, "external_urls"=>{"spotify"=>"http://open.spotify.com/user/wizzler/playlists/53Y8wT46QIMz5H4WQ8O22c"}, "href"=>"https://api.spotify.com/v1/users/wizzler/playlists/53Y8wT46QIMz5H4WQ8O22c", "id"=>"53Y8wT46QIMz5H4WQ8O22c", "images"=>[], "name"=>"Wizzlers Big Playlist", "owner"=>{"external_urls"=>{"spotify"=>"http://open.spotify.com/user/wizzler"}, "href"=>"https://api.spotify.com/v1/users/wizzler", "id"=>"wizzler", "type"=>"user", "uri"=>"spotify:user:wizzler"}, "public"=>true, "tracks"=>{"href"=>"https://api.spotify.com/v1/users/wizzler/playlists/53Y8wT46QIMz5H4WQ8O22c/tracks", "total"=>30}, "type"=>"playlist", "uri"=>"spotify:user:wizzler:playlist:53Y8wT46QIMz5H4WQ8O22c"}, {"collaborative"=>false, "external_urls"=>{"spotify"=>"http://open.spotify.com/user/wizzlersmate/playlists/1AVZz0mBuGbCEoNRQdYQju"}, "href"=>"https://api.spotify.com/v1/users/wizzlersmate/playlists/1AVZz0mBuGbCEoNRQdYQju", "id"=>"1AVZz0mBuGbCEoNRQdYQju", "images"=>[], "name"=>"Another Playlist", "owner"=>{"external_urls"=>{"spotify"=>"http://open.spotify.com/user/wizzlersmate"}, "href"=>"https://api.spotify.com/v1/users/wizzlersmate", "id"=>"wizzlersmate", "type"=>"user", "uri"=>"spotify:user:wizzlersmate"}, "public"=>true, "tracks"=>{"href"=>"https://api.spotify.com/v1/users/wizzlersmate/playlists/1AVZz0mBuGbCEoNRQdYQju/tracks", "total"=>58}, "type"=>"playlist", "uri"=>"spotify:user:wizzlersmate:playlist:1AVZz0mBuGbCEoNRQdYQju"}], "limit"=>2, "next"=>nil, "offset"=>0, "previous"=>nil, "total"=>2}
      ))
      @env = { "rack.session" => { "uuid" => @user.uuid } }
    end

    describe 'GET /playlists' do
      it 'returns correct status code and conforms to schema' do
        get '/playlists/spotify', {}, @env
        assert_equal 200, last_response.status
        assert_schema_conform
      end
    end

    describe 'POST /playlists' do
      it 'returns correct status code and conforms to schema' do
        header "Content-Type", "application/json"
        post '/playlists/spotify', MultiJson.encode({}), @env

        # TODO: How to define explcitly disabled endpoints in schema?
        assert_equal 403, last_response.status
        e = assert_raises Committee::InvalidResponse do
          assert_schema_conform
        end
        assert e.message =~ /undefined in schema/
      end
    end

    describe 'GET /playlists/:id' do
      it 'returns correct status code and conforms to schema' do
        get "/playlists/spotify/53Y8wT46QIMz5H4WQ8O22c", {}, @env
        assert_equal 200, last_response.status
        assert_schema_conform
      end
    end

    describe 'PATCH /playlists/:id' do
      it 'returns correct status code and conforms to schema' do
        header "Content-Type", "application/json"
        patch "/playlists/rdio/53Y8wT46QIMz5H4WQ8O22c", MultiJson.encode({}), @env

        assert_equal 403, last_response.status
        e = assert_raises Committee::InvalidResponse do
          assert_schema_conform
        end
        assert e.message =~ /undefined in schema/
      end
    end

    describe 'DELETE /playlists/:id' do
      it 'returns correct status code and conforms to schema' do
        delete "/playlists/rdio/53Y8wT46QIMz5H4WQ8O22c", {}, @env

        assert_equal 403, last_response.status
        e = assert_raises Committee::InvalidResponse do
          assert_schema_conform
        end
        assert e.message =~ /undefined in schema/
      end
    end
  end
end
