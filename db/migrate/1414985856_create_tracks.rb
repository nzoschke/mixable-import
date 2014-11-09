Sequel.migration do
  change do
    create_table(:tracks) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at

      text         :key, index: true

      text         :artist
      text         :album
      text         :name
      integer      :duration

      column       :isrcs, "text[]"

      text         :spotify_id
      text         :spotify_isrc
    end
  end
end
