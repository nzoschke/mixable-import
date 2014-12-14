# Mixable Sync

Rdio to Spotify playlist sync.

[![Circle CI](https://circleci.com/gh/nzoschke/mixable-import.png?circle-token=49f4c711685f084fe5e93990001a0b2c9c5445f4)](https://circleci.com/gh/nzoschke/mixable-import)

## Quick Start

Install [Boot2Docker](https://github.com/boot2docker/osx-installer/releases)
and [fig](http://www.fig.sh/install.html).

Copy .env.sample to .env. Add Mixable Rdio and Spotify application keys. Add
integration test Rdio and Spotify user OAuth keys.

Run specs in a fig environment:

```sh
$ boot2docker up
$ $(boot2docker shellinit)
$ dotenv fig run test
```

## TODO

Rdio
  Collection

Dev/Test
  Mount code in container /app directory
  Integrate with CircleCI
    https://blog.abevoelker.com/simple-free-continuous-integration-of-rails-docker-images-using-fig-make-and-circleci/

Frontend
  Awesome phone demo
    Import progress on Spotify tab

    RDIO COLLECTION
    SPOTIFY TRACKS for "Rdio /" Playlists

    Async Rdio / Spotify playlist fetching?

    Rdio / Spotify tab switch awesomeness
      update
      create
      synced

      perfect
      missing

    Try to append data on polling instead of re-draw...

    --

    Nav Tabs
      http://getbootstrap.com/components/#nav-tabs

    Progress Bar
      http://getbootstrap.com/components/#progress

    List Group w/ badges
      http://getbootstrap.com/components/#list-group-badges

    Panel w/ Table + Responsive + Collapse
      http://getbootstrap.com/components/#panels-tables
      http://getbootstrap.com/css/#tables-responsive
      http://getbootstrap.com/javascript/#collapse

    rdio_playlist
      synced
        exists and track count matches
      update
        exists and track count doesnt match
      create
        doesn't exist

      fully matched
      missing tracks

    ________
    | Rdio |  Spotify   About
    ==================--------------------
    | Owned                           (3)|
    --------------------------------------
    | Δ Radiohead                    (11)|
    --------------------------------------
    | Δ Pitchfork                   (100)|
    --------------------------------------
    | = Mixable                      (14)|
    |....................................|
    | 1. Shaky Dog       ⨯ Ghostface Kill|
    | 2. Gone Daddy Gone ⨯ Gnarls Barkely|
    | 3. Take Time       ⨯ The Books     |


            ___________
      Rdio  | Spotify | About
    ==================--------------------
    | Sync                            (2)|
    --------------------------------------
    | ⇒ Radiohead                    (10)|
    --------------------------------------
    | + Pitchfork                   (100)|
    --------------------------------------
    | = Mixable                      (14)|
    --------------------------------------
    | Other                          (11)|
    --------------------------------------



API schema
  /auth/:provider
  /auth/:provider/callback

    GET /auth/rdio
    GET /auth/rdio/callback
    GET /auth/spotify
    GET /auth/spotify/callback

    DELETE /auth
      GET /auth?_method=DELETE

  /playlists/:provider

    GET /playlists/rdio
    GET /playlists/spotify

  /imports/:provider
    PUT /imports/spotify
    GET /imports/spotify

    TODO: Better response schema
    TODO: Lock around PUT when track matching or another import is in progress.


  TODO
    pliny-generate endpoint auth
    User.find_or_create_by_rdio_auth / User.find_or_create_by_spotify_auth
    Acceptance tests

  Marketing Pages
    Pro Features - Workflows for Music Professionals!
      missing tracks
        collaborative playlist + libspotify bot
      Spotify -> Rdio
      Spotify <-> Rdio
      Ignore Playlists
      Rename Playlists
        Stateful?
      Widgets
      Player
      ScratchPad Integration
      Analytics

Dashboard
  Security
    Dependency tracker
    Alert when Heroku changes?
    Alert when rubygems changes?
    Cross-check with 0-days

  Performance
    Response time
      Database time
      External service call time

    Work queue time and throughput

    Client rendering time?

  Availability
    Response status
    Pingdom?
    Google Analytics

  Rate of change
    Git commits
    Heroku deploys

  Cost
    Money in
      Tip jar?
    Money out
      Heroku invoice API?

Metrics
  CLI tools
    hutils fork?
    metrics audit
    unicode visualizations?

Work Queue
  Sidekiq
    instrumentation
      request_id
    requeueing strategy
    test strategy

Integration Tests
  Reset Rdio and Spotify on start

Libspotify
  go-libspotify / CLI
  Facebook bot

Postgres / Sequel / pg_json
  Query syntax


