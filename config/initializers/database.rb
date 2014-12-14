Sequel.extension :core_extensions, :pg_array, :pg_json, :pg_json_ops
db = Sequel.connect(Config.database_url, max_connections: Config.db_pool)
db.extension :pliny_instrumentation