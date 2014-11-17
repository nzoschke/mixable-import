class Serializers::Playlist < Serializers::Base
  structure(:default) do |arg|
    {
      created_at: arg.created_at.try(:iso8601),
      id:         arg.uuid,
      updated_at: arg.updated_at.try(:iso8601),
    }
  end

  structure(:spotify) do |rp|
    # Turns a Rdio playlist (in the Rdio API Playlist JSON format) into a Spotify-esque playlist object
    rdio_keys = rp["tracks"].map { |rt| rt["key"] }
    key_map   = Track.where(rdio_key: rdio_keys).to_hash(:rdio_key, :spotify_id)

    items = rp["tracks"].map do |rt|
      {
        id:           key_map[rt["key"]],
        name:         rt["name"],
        duration_ms:  rt["duration"] * 1000,
        album:        { type: "album", name: rt["album"] },
        artists:      [{ type: "artist", name: rt["artist"] }],
        external_ids: { isrc: rt["isrcs"][0], rdio_key: rt["key"] }
      }
    end

    {
      created_at:   Time.now.try(:iso8601),
      updated_at:   Time.now.try(:iso8601),
      id:           rp["key"],

      name:         rp["name"],
      description:  rp["description"] || "",
      type:         "playlist",

      tracks: {
        total:      items.count,
        matched:    key_map.values.count { |v| v },
        processed:  key_map.count,
        items:      items
      }
    }
  end
end
