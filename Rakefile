require "pliny/tasks"

# Add your rake tasks to lib/tasks!
Dir["./lib/tasks/*.rake"].each { |task| load task }

task :spec do
  require "rspec/core"
  code = RSpec::Core::Runner.run(
    ["./spec"],
    $stderr, $stdout)
  exit(code) unless code == 0
end

task :default => :spec

task :analytics do
  # # Load all the data into an analytics database
  # `heroku pgbackups:capture`
  # `curl -o latest.dump $(heroku pgbackups:url)`
  # `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d myapp-analytics latest.dump`

  # Run some tests against the database
  require "rspec/core"
  code = RSpec::Core::Runner.run(
    ["./analytics"],
    $stderr, $stdout)
  exit(code) unless code == 0
end
