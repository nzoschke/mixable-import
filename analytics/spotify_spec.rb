require_relative "./analytics_helper"

class ISRC
  attr_accessor :isrc, :rdio_tracks, :spotify_tracks

  def initialize(isrc)
    @isrc = isrc
  end

  def get_rdio_tracks
    @rdio_tracks ||= JSON.parse(ISRC.rdio_client.post('http://api.rdio.com/1/',
      method: 'getTracksByISRC',
      isrc:   @isrc,
      extras: "isrcs"  # TODO: better extras
    ).body)['result']
  end

  def get_spotify_tracks
    @spotify_tracks ||= JSON.parse(ISRC.spotify_client.get("search", params: {
      type: "track",
      q:    "isrc:#{isrc}"
    }).body)['tracks']['items']
  end

  def rdio_metadata(r)
    {
      isrc:     r['isrcs'][0],
      # rdio_key: r['key'],
      artist:   r['artist'],
      album:    r['album'],
      name:     r['name'],
      duration: r['duration']
    }
  end

  def spotify_metadata(r)
    {
      isrc:       r['external_ids']['isrc'],
      # spotify_id: r['id'],
      artist:     r['artists'][0]['name'],
      album:      r['album']['name'],
      name:       r['name'],
      duration:   r['duration_ms'] / 1000
    }
  end

  def match
    # match a single Rdio Key to a Spotify ID with a confidence interval
    r = get_rdio_tracks.first
    s = get_spotify_tracks.first

    [rdio_metadata(r), spotify_metadata(s)]
  end

  def self.rdio_client
    # Unauthorized Rdio client
    # http://www.rdio.com/developers/docs/web-service/oauth/ref-signing-requests
    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuth::AccessToken.new(consumer)
  end

  def self.spotify_client
    # Unauthorized Spotify client
    # https://developer.spotify.com/web-api/authorization-guide/#client_credentials_flow
    # Access token generated with `foreman run bin/keys`
    # TODO: handle key expiration
    consumer = OAuth2::Client.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], site: 'https://api.spotify.com/v1')
    client = OAuth2::AccessToken.new(consumer, ENV['SPOTIFY_ACCESS_TOKEN'])
  end
end

describe ISRC do
  xit "dumps the number of tracks on Rdio and Spotify" do
    puts ""
    Track.each do |track|
      i = ISRC.new(track.isrc)
      puts "#{track.rdio_key}\t#{i.isrc}\t#{i.get_rdio_tracks.length}\t#{i.get_spotify_tracks.length}"
    end
  end

  xit "some songs dont have an ISRC" do
    "t35264922"
  end

  context "corresponds to 0 Rdio Track(s)" do
    it "corresponds to 0 Spotify Track(s)" do
      isrc = ISRC.new("USABC1400001")
      assert_equal 0, isrc.get_rdio_tracks.length
      assert_equal 0, isrc.get_spotify_tracks.length
    end

    xit "corresponds to 1 Spotify Track(s)" do
      isrc = ISRC.new("USA371087682")
      assert_equal 0, isrc.get_rdio_tracks.length
      assert_equal 1, isrc.get_spotify_tracks.length
    end

    xit "corresponds to 2 Spotify Track(s)" do
      isrc = ISRC.new("USA371087682")
      assert_equal 0, isrc.get_rdio_tracks.length
      assert_equal 2, isrc.get_spotify_tracks.length
    end
  end

  context "corresponds to 1 Rdio Track(s)" do
    it "corresponds to 0 Spotify Track(s)" do
      isrc = ISRC.new("USZXT1055823")
      assert_equal 1, isrc.get_rdio_tracks.length
      assert_equal 0, isrc.get_spotify_tracks.length
    end

    it "corresponds to 1 Spotify Track(s)" do
      isrc = ISRC.new("USCA29401248")
      assert_equal 1, isrc.get_rdio_tracks.length
      assert_equal 1, isrc.get_spotify_tracks.length

      rdio_track, spotify_track = isrc.match
      assert_equal rdio_track, spotify_track
    end

    it "corresponds to 2 Spotify Track(s)" do
      isrc = ISRC.new("GBAAA0900975")
      assert_equal 1, isrc.get_rdio_tracks.length
      assert_equal 2, isrc.get_spotify_tracks.length
    end
  end

  context "corresponds to 2 Rdio Track(s)" do
    it "corresponds to 0 Spotify Track(s)" do
      isrc = ISRC.new("USUS10610239")
      assert_equal 2, isrc.get_rdio_tracks.length
      assert_equal 0, isrc.get_spotify_tracks.length
    end

    it "corresponds to 1 Spotify Track(s)" do
      isrc = ISRC.new("GB2LD0900911")
      assert_equal 2, isrc.get_rdio_tracks.length
      assert_equal 1, isrc.get_spotify_tracks.length
    end

    it "corresponds to 2 Spotify Track(s)" do
      isrc = ISRC.new("USK110617810")
      assert_equal 2, isrc.get_rdio_tracks.length
      assert_equal 2, isrc.get_spotify_tracks.length
    end
  end

  context "corresponds to N Rdio Track(s)" do
    it "corresponds to N Spotify Track(s)" do
      isrc = ISRC.new("GBZN81300014")
      assert_equal 17, isrc.get_rdio_tracks.length
      assert_equal 16, isrc.get_spotify_tracks.length
    end
  end
end

xdescribe User do
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

  xit "tries a fuzzy search" do
    Track.where(spotify_id: nil).each do |track|
      track.fuzzy_search_spotify
    end
  end

  xit "lists the number of tracks on each service by ISRC" do
  end
end
