module Endpoints
  class Healths < Base
    namespace "/healths" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        encode []
      end

      get "/change" do
        # Sample GitHub Statistics API
        # https://developer.github.com/v3/repos/statistics/
        # Contributors, additions, deletions and commit counts
        stats = GithubClient.get_statistics("nzoschke", "mixable-import")

        additions = deletions = commits = 0
        stats.each do |contributor_stats|
          contributor_stats["weeks"].each do |week|
            additions += week["a"]
            deletions += week["d"]
            commits   += week["c"]
          end
        end

        Pliny.log({
          "sample#repo.additions" => additions,
          "sample#repo.deletions" => deletions,
          "sample#repo.commits"   => commits,
        })
      end

      get "/cost" do
        # Sample Heroku Invoice API
        # Add in fixed monthly costs
      end
    end
  end
end

module GithubClient
  def self.get_statistics(owner, repo)
    client = GithubClient.authorized_client
    client.get("repos/#{owner}/#{repo}/stats/contributors").parsed
  end

  def self.authorized_client
    consumer = OAuth2::Client.new(ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], site: "https://api.github.com")
    client = OAuth2AccessToken.new(consumer, ENV["GITHUB_USER_TOKEN"])
  end
end
