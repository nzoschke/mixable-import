require "spec_helper"

describe Endpoints::Healths do
  include Rack::Test::Methods

  describe "GET /healths" do
    it "succeeds" do
      expect(GithubClient).to receive(:get_repo_statistics) { [{ "weeks" => [{ "a" => 2, "d" => 1, "c" => 1 }] }] }

      expect(HerokuClient).to receive(:get_invoices)
      expect(HerokuClient).to receive(:percent_of_month) { 100.0 }

      expect(SpotifyClient).to receive(:get_user) { { "followers" => { "total" => 7 } } }
      expect(SpotifyClient).to receive(:get_public_playlists) { { "items" => [{ "followers" => { "total" => 3 }, "tracks" => { "total" => 10 } }] } }

      expect(RdioClient).to receive(:get_track) { {"key" => "t1234567" } }

      expect(Sidekiq).to receive(:redis).at_most(2).times { { "uptime_in_seconds" => 19, "connected_clients" => 1, "used_memory_peak" => 13 } }

      expect(Sidekiq::Queue).to   receive(:new) { OpenStruct.new(latency: 10) }
      expect(Sidekiq::Stats).to   receive(:new) { OpenStruct.new(processed: 1, failed: 0, enqueued: 0, scheduled_size: 0, retry_size: 0, dead_size: 0) }
      expect(Sidekiq::Workers).to receive(:new) { OpenStruct.new(size: 0) }

      get "/healths"
      assert_equal 200, last_response.status
      r = JSON.parse last_response.body

      assert_equal ["github", "heroku", "spotify", "postgres", "rdio", "redis", "sidekiq"], r.keys

      assert_equal(
        { "sample#github.repo.additions" => 2, "sample#github.repo.deletions" => 1, "sample#github.repo.commits" => 1 },
        r["github"]
      )

      assert_equal(
        { "sample#heroku.cost" => 8700.0, "sample#github.cost" => 700.0, "sample#spotify.cost" => 999.0 },
        r["heroku"]
      )

      assert_equal(
        { "sample#spotify.user.followers" => 7, "sample#spotify.user.playlists.followers" => 3, "sample#spotify.user.playlists.tracks" => 10 },
        r["spotify"]
      )

      assert_equal(
        { "sample#postgres.tracks" => 0, "sample#postgres.users" => 0 },
        r["postgres"]
      )

      assert_equal(
        { "key" => "t1234567" },
        r["rdio"]
      )

      assert_equal(
        { "sample#redis.uptime" => 19, "sample#redis.clients" => 1, "sample#redis.memory" => 13 },
        r["redis"]
      )

      assert_equal(
        { "sample#sidekiq.processed" => 1, "sample#sidekiq.failed" => 0, "sample#sidekiq.busy" => 0, "sample#sidekiq.enqueued" => 0, "sample#sidekiq.scheduled" => 0, "sample#sidekiq.retries" => 0, "sample#sidekiq.dead" => 0, "sample#sidekiq.default_latency" => 10 },
        r["sidekiq"]
      )
    end

    it "fails" do
      expect(GithubClient).to receive(:get_repo_statistics)
      expect(HerokuClient).to receive(:get_invoices)
      expect(SpotifyClient).to receive(:get_user)
      expect(SpotifyClient).to receive(:get_public_playlists)
      expect(RdioClient).to receive(:get_track)
      expect(Sidekiq).to receive(:redis).at_most(5).times

      get "/healths"
      assert_equal 500, last_response.status
      r = JSON.parse last_response.body

      assert_equal(
        {
          "github" => "error", "heroku" => "error", "spotify" => "error", "rdio" => "error", "redis" => "error", "sidekiq" => "error",
          "postgres" => { "sample#postgres.tracks" => 0, "sample#postgres.users" => 0 }
        },
        r
      )
    end
  end
end
