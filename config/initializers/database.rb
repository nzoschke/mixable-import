Sequel.extension :core_extensions, :pg_array, :pg_json
Sequel.connect(Config.database_url, max_connections: Config.db_pool)
