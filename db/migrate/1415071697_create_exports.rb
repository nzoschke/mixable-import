Sequel.migration do
  change do
    create_table(:exports) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at

      text         :rdio_username
      text         :rdio_token
      text         :rdio_secret
      text         :state
    end
  end
end
