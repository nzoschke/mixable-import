require_relative "../client"
require "levenshtein"

class Track < Sequel::Model
  plugin :timestamps

  def match_by_first_result
    # Naive matching for analytics purposes 
    if match = SpotifyClient.search_by_isrcs(rdio_isrcs).first
      { match["id"] => SpotifyClient.metadata(match) }
    else
      { nil => {} }
    end
  end

  def name_artist_album_duration_s(h)
    "#{h[:name]} - #{h[:artist]} - #{h[:album]} - #{h[:duration]}"
  end

  def match_by_total_edit_distance
    rs = "#{rdio_name} - #{rdio_artist} - #{rdio_album} - #{rdio_duration}"

    min_d = rs.length + 1
    match = { nil => {} }

    SpotifyClient.search_by_isrcs(rdio_isrcs).each do |r|
      ss = name_artist_album_duration_s(SpotifyClient.metadata(r))
      d = Levenshtein.distance rs, ss

      if d < min_d
        match = { r["id"] => SpotifyClient.metadata(r) }
        min_d = d
      elsif d == min_d
        # TODO
      end
    end

    match
  end

  def match_spotify!
    matches = match_by_total_edit_distance

    spotify_id = matches.keys[0]
    match = matches[spotify_id]

    isrcs = []
    matches.each do |id, h|
      isrcs << h[:isrc]
    end

    update(
      rdio_isrcs:           "{#{rdio_isrcs.compact.join(',')}}",
      spotify_id:           spotify_id,
      spotify_name:         match[:name],
      spotify_album:        match[:album],
      spotify_artist:       match[:artist],
      spotify_duration_ms:  match[:duration_ms],
      spotify_isrcs:        "{#{isrcs.compact.join(',')}}",
      isrc:                 match[:isrc]
    )
  end
end
