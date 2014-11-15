Sequel.extension :core_extensions, :pg_array, :pg_json
db = Sequel.connect(Config.database_url, max_connections: Config.db_pool, loggers: [Logger.new($stdout)])
db.extension :pliny_instrumentation
