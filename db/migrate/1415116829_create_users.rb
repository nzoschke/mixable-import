Sequel.migration do
  change do
    create_table(:users) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at

      text         :rdio_key, index: true
      text         :rdio_username
      text         :rdio_token
      text         :rdio_secret

      json         :rdio_playlists

      text         :spotify_id, index: true
      text         :spotify_username
      text         :spotify_token
      text         :spotify_refresh_token
      timestamptz  :spotify_expires_at

      json         :spotify_playlists
    end
  end
end
