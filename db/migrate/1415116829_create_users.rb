Sequel.migration do
  change do
    create_table(:users) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at

      text         :key
      text         :url
      text         :token
      text         :secret

      json         :playlists
    end
  end
end
