module Sequel
  module PlinyInstrumentation
    # Proof of Concept!
    # This assumes that sequel is normalizing statements and that tables are named sanely
    # There is no guarantee of completeness or the performance of this instrumentation

    def log_summary(sql, start, at)
      at ||= "finish"

      m = sql.match(/^(UPDATE) "([a-z_]+)"/)            ||
          sql.match(/^(INSERT INTO) "([a-z_]+)"/)       ||
          sql.match(/^(SELECT) .* (FROM) "([a-z_]+)"/)

      if m
        Pliny.log(
          database:   true,
          at:         at,
          sql:        m[1..4].join(" "),
          elapsed:    (Time.now - start).to_f
        )
      end
    end

    def log_yield(sql, args=nil)
      return yield if @loggers.empty?
      start = Time.now
      at    = "finish"

      begin
        yield
      rescue => e
        at = "exception"
        log_exception(e, sql) # TODO: Pliny exception logging strategy?
        raise
      ensure
        log_summary(sql, start, at)
      end
    end
  end

  Database.register_extension(:pliny_instrumentation, PlinyInstrumentation)
end