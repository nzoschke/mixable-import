# TODO
Rdio
  Collection

Frontend
  Awesome phone demo
    Better workflow UI
    Better mobile UI
    Private hooks to reset stuff
    Easy Rdio / Spotify passwords
      Always show spotify dialog

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

    ________
    | Rdio |  Spotify   Import  Disconnect
    ==================--------------------
    | Collection                    (100)|
    --------------------------------------
    | Feist                          (14)|
    |....................................|
    | Feist | So Sorry      | The Reminde|
    | Feist | I Feel It All | The Reminde|

    Try to append data on polling instead of re-draw...


API schema
  GET /rdio/auth
  PUT /rdio/auth/callback
  GET /spotify/auth
  PUT /spotify/auth/callback

  GET /rdio/playlists
  GET /spotify/playlists

  PUT /spotify/import
  GET /spotify/import

  vs

  GET /playlists/rdio
  GET /playlists/spotify
  GET /imports/spotify
  PUT /imports/spotify

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


