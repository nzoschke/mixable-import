Sequel.migration do
  change do
    create_table(:users) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at

      text         :key, index: true
      text         :url
      text         :token
      text         :secret

      json         :playlists

      text         :spotify_token
      text         :spotify_refresh_token
      timestamptz  :spotify_expires_at
      text         :spotify_id, index: true
    end
  end
end
