class Serializers::Import < Serializers::Base
  structure(:default) do |arg|
    {
      created_at: arg.created_at.try(:iso8601),
      id:         arg.uuid,
      updated_at: arg.updated_at.try(:iso8601),
      playlists:  arg.spotify_playlists,
    }
  end
end
