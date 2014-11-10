Sequel.migration do
  change do
    create_table(:tracks) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at

      text         :rdio_key, index: true

      text         :rdio_name
      text         :rdio_artist
      text         :rdio_album
      integer      :rdio_duration
      column       :rdio_isrcs, "text[]"

      text         :spotify_id, index: true

      text         :spotify_name
      text         :spotify_album
      text         :spotify_artist
      float        :spotify_duration_ms
      column       :spotify_isrcs, "text[]"

      text         :isrc, index: true
    end
  end
end
