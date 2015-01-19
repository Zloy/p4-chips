require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'standalone_migrations'

StandaloneMigrations::Tasks.load_tasks
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: [:rubocop, 'db:drop', 'db:setup', :spec]
task test: :spec
