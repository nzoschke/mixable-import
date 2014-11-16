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
    items = rp["tracks"].map do |rt|
      {
        name:         rt["name"],
        duration_ms:  rt["duration"] * 1000,
        album:        { type: "album", name: rt["album"] },
        artists:      [{ type: "artist", name: rt["artist"] }],
        external_ids: { isrc: rt["isrcs"][0] }
      }
    end

    {
      created_at:   Time.now.try(:iso8601),
      updated_at:   Time.now.try(:iso8601),
      id:           "10f0c10c-cf69-4524-a8ec-cb302de24aca",

      name:         rp["name"],
      description:  rp["description"] || "",
      type:         "playlist",

      tracks: {
        total: items.count,
        items: items
      }
    }
  end
end
