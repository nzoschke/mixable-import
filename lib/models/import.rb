class Import < Sequel::Model
  plugin :timestamps
  many_to_one :user, key: :user_uuid

  def self.start_spotify!(user, opts={})
    created_at = opts[:created_at] || Time.now
    updated_at = opts[:updated_at] || Time.now
    expires_in = opts[:expires_in] || 120

    # Verify that track matching is not in progress
    playlists = Serializers::Playlist.new(:rdio).serialize(user.rdio_playlists_to_a)

    total     = 0
    processed = 0

    playlists.each do |playlist|
      total     += playlist[:tracks][:total]
      processed += playlist[:tracks][:processed]
    end

    if processed < total
      raise ImportError.new("Track matching in progress")
    end

    if i = user.imports.last
      raise ImportError.new("Import in progress") unless i[:created_at] < created_at - expires_in
    end

    self.create(
      user:       user,
      created_at: created_at,
      updated_at: updated_at,
      spotify_playlists: Sequel.pg_json({
        total:      user.rdio_playlists_to_a.count,
        added:      0,
        processed:  0,
        items:      []
      })
    )
  end

  def work_spotify!
    playlists = spotify_playlists

    user.rdio_playlists_to_a.each do |playlist|
      name          = "Rdio / #{playlist['name']}"
      track_uris    = []

      playlist["tracks"].each do |track|
        if track = Track[rdio_key: track['key']]
          track_uris << "spotify:track:#{track.spotify_id}" if track.spotify_id
        end
      end

      p = SpotifyClient.create_or_update_playlist(user, name, track_uris)

      # TODO: failures and duplicates?
      playlists["added"]     += 1
      playlists["processed"] += 1
      playlists["items"]     << p["id"]

      # FIXME: why doesn't update work?!
      spotify_playlists = Sequel.pg_json(playlists)
      save
    end

    self
  end
end

class ImportError < Exception ; end