Yosemite Development
  System ruby
    ruby 2.0.0p481 (2014-05-08 revision 45883) [universal.x86_64-darwin14])
    $ for i in `/usr/bin/gem list --no-versions`; do sudo /usr/bin/gem uninstall -aIx $i; done

  brew ruby
    ruby: stable 2.1.4 (bottled), HEAD
  boot2docker
    what image?

Bundler
  homebrew postgres
    missing libpq...
      $ sudo su
      # env ARCHFLAGS="-arch x86_64" gem install pg

    The uuid-ossp module for Postgres?

    FATAL:  could not open directory "pg_tblspc": No such file or directory
      $ mkdir -p /usr/local/var/postgres/{pg_tblspc,pg_twophase,pg_stat_tmp}/
      $ touch /usr/local/var/postgres/{pg_tblspc,pg_twophase,pg_stat_tmp}/.keep

    uuid_generate_v4

Pliny
  bin/setup
    Your Ruby version is 2.0.0, but your Gemfile specified 2.1.4
    needs postgres running

  $ bundle exec pliny-generate model playlist
  /usr/local/Cellar/ruby/2.1.4/lib/ruby/gems/2.1.0/gems/pliny-0.4.0/lib/pliny/version.rb:2: warning: already initialized constant Pliny::VERSION
  /usr/local/lib/ruby/gems/2.1.0/gems/pliny-0.4.0/lib/pliny/version.rb:2: warning: previous definition of VERSION was here

  $ bundle exec rake
  rake aborted!
  Errno::EBADF: Bad file descriptor @ fptr_finalize - /usr/local/lib/ruby/gems/2.1.0/gems/backports-3.6.0/lib/backports/1.9.1/io/open.rb
  /usr/local/lib/ruby/gems/2.1.0/gems/backports-3.6.0/lib/backports/1.9.1/io/open.rb:2:in `close'

  Gemfile.lock backports (3.6.1)
  http://stackoverflow.com/questions/26130693/gitlab-ci-installation-error

40 minutes to get working on Yosemite!

Endpoint
  not obvious how to add to router

Schema
  not clear how to modify the yaml
  not clear to regenerate json

Heroku
  $ bundle exec rake db:setup
  rake aborted!
  Sequel::DatabaseConnectionError: PG::ConnectionBad: could not connect to server: No such file or directory
    Is the server running locally and accepting
    connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?

--

GET /auth/rdio
GET /auth/rdio/callback

PUT /exports
  matching
  done
  error

PUT /imports
  appending
  done
  error

(Rdio) User
  username
  has_many :playlists

Playlist
  has_many :tracks

Track
  name
  artist
  album
  isrc
  rdio_key
  spotify_id

April Fools - 12 Tracks
  100% match. Details...

April Fools - 12 Tracks
  98% match. Details...
