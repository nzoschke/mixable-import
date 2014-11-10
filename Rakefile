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
  # Optionally
  #   Dump playlist jsons from production into analytics/*.json
  #   private API w/ curl? database backup, restore, extract?

  # Run some tests against the fixtures
  require "rspec/core"
  code = RSpec::Core::Runner.run(
    ["./analytics"],
    $stderr, $stdout)
  exit(code) unless code == 0
end
