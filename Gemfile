source "https://rubygems.org"
ruby "2.1.5"

gem "multi_json"
gem "oj"
gem "pg"
gem "pliny", "~> 0.5", github: "nzoschke/pliny"
gem "pry"
gem "pry-doc"
gem "puma", "~> 2.10"
gem "rack-ssl"
gem "rake"
gem "rollbar"
gem "sequel", "~> 4.16"
gem "sequel-paranoid"
gem "sequel_pg", "~> 1.6", require: "sequel"
gem "sinatra", "~> 1.4", require: "sinatra/base"
gem "sinatra-contrib", require: ["sinatra/namespace", "sinatra/reloader"]
gem "sinatra-router"
gem "sucker_punch"

gem "levenshtein"
gem "omniauth-rdio"
gem "omniauth-spotify"
gem "sidekiq"

group :development, :test do
  gem "pry-byebug"
end

group :test do
  gem "committee"
  gem "database_cleaner"
  gem "dotenv"
  gem "rack-test"
  gem "rspec"
end
