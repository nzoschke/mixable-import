Sequel.migration do
  change do
    create_table(:imports) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at

      uuid         :user_uuid, null: false

      json         :spotify_playlists
    end
  end
end
