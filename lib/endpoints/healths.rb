require "active_support/core_ext"

module Endpoints
  class Healths < Base
    namespace "/healths" do
      before do
        content_type :json, charset: 'utf-8'
      end

      def check(&proc)
        # TODO: Log exceptions but continue...
        begin
          data = yield proc
          Pliny.log(data)
          data
        rescue
          :error
        end
      end

      get do
        r = {
          github:   check { GithubClient.get_repo_statistics("nzoschke", "mixable-import") },
          heroku:   check { HerokuClient.get_app_costs("mixable") },
          spotify:  check { SpotifyClient.get_user_statistics("mixable.net") },
          postgres: check { { "sample#postgres.tracks" => Track.count, "sample#postgres.users" => User.count } },
          rdio:     check { RdioClient.get_track(Track.new(rdio_key: "t2714517")).select { |k| k == "key" } },
          redis:    check { SidekiqClient.get_redis_statistics },
          sidekiq:  check { SidekiqClient.get_queue_statistics }
        }

        status 500 if r.values.include? :error
        encode r
      end

    end
  end
end

module GithubClient
  def self.get_repo_statistics(owner, repo)
    # Sample GitHub Statistics API
    # https://developer.github.com/v3/repos/statistics/
    # Contributors, additions, deletions and commit counts
    client = GithubClient.authorized_client
    stats = client.get("repos/#{owner}/#{repo}/stats/contributors").parsed

    additions = deletions = commits = 0
    stats.each do |contributor_stats|
      contributor_stats["weeks"].each do |week|
        additions += week["a"]
        deletions += week["d"]
        commits   += week["c"]
      end
    end

    {
      "sample#github.repo.additions" => additions,
      "sample#github.repo.deletions" => deletions,
      "sample#github.repo.commits"   => commits,
    }
  end

  def self.authorized_client
    consumer = OAuth2::Client.new(ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], site: "https://api.github.com")
    client = OAuth2AccessToken.new(consumer, ENV["GITHUB_TOKEN"])
  end
end

module HerokuClient
  @@token      = ENV["HEROKU_TOKEN"]
  @@expires_at = Time.now - 10

  def self.get_app_costs(app_name)
    # TODO: Invoices API is useless. Collaborator doesn't get data.
    invoices = HerokuClient.get_invoices

    now = Time.now.to_f
    month_start = Date.today.at_beginning_of_month.to_time.to_f
    month_end   = Date.today.at_end_of_month.to_time.to_f
    percent_of_month = (now - month_start) / (month_end - month_start)

    {
      "sample#heroku.cost"   => 87.00 * percent_of_month,
      "sample#github.cost"   =>  7.00 * percent_of_month,
      "sample#spotify.cost"  =>  9.99 * percent_of_month,
    }
  end

  def self.get_invoices
    client = HerokuClient.authorized_client
    invoices = client.get("account/invoices")
  end

  def self.authorized_client
    if @@expires_at < Time.now
      consumer = OAuth2::Client.new(ENV["HEROKU_CLIENT_ID"], ENV["HEROKU_CLIENT_SECRET"], site: "https://id.heroku.com")
      client = OAuth2AccessToken.new(consumer, ENV["HEROKU_TOKEN"], { refresh_token: ENV["HEROKU_REFRESH_TOKEN"] }).refresh!
      @@token      = client.token
      @@expires_at = Time.at client.expires_at
    end

    puts @@token.inspect
    consumer = OAuth2::Client.new(ENV["HEROKU_CLIENT_ID"], ENV["HEROKU_CLIENT_SECRET"], site: "https://api.heroku.com")
    client = OAuth2AccessToken.new(consumer, @@token, { refresh_token: ENV["HEROKU_REFRESH_TOKEN"] })
  end
end

module SidekiqClient
  require "sidekiq/api"

  def self.get_redis_statistics
    Sidekiq.redis do |conn|
      info = conn.info
      {
        "sample#redis.uptime"   => info["uptime_in_days"],
        "sample#redis.clients"  => info["connected_clients"],
        "sample#redis.memory"   => info["used_memory_peak"],
      }
    end
  end

  def self.get_queue_statistics
    queue   = Sidekiq::Queue.new
    stats   = Sidekiq::Stats.new
    workers = Sidekiq::Workers.new

    {
      "sample#sidekiq.processed"        => stats.processed,
      "sample#sidekiq.failed"           => stats.failed,
      "sample#sidekiq.busy"             => workers.size,
      "sample#sidekiq.enqueued"         => stats.enqueued,
      "sample#sidekiq.scheduled"        => stats.scheduled_size,
      "sample#sidekiq.retries"          => stats.retry_size,
      "sample#sidekiq.dead"             => stats.dead_size,
      "sample#sidekiq.default_latency"  => queue.latency,
    }
  end
end

module SpotifyClient
  def self.get_user_statistics(user_id)
    user      = SpotifyClient.get_user(user_id)
    playlists = SpotifyClient.get_public_playlists(user_id)

    followers = 0
    tracks    = 0
    playlists["items"].each do |p|
      followers += p["followers"]["total"]
      tracks    += p["tracks"]["total"]
    end

    {
      "sample#spotify.user.followers"           => user["followers"]["total"],
      "sample#spotify.user.playlists.followers" => followers,
      "sample#spotify.user.playlists.tracks"    => tracks,
    }
  end
end
